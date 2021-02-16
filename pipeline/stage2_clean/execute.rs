/*
  WGU Capstone Project
  Copyright (C) 2021 Will Burklund

  This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU Affero General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU Affero General Public License for more details.

  You should have received a copy of the GNU Affero General Public License
  along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/

use std::collections::HashSet;
use std::iter::Iterator;
use std::path::Path;
use rusoto_core::{Region, RusotoError};
use rusoto_ssm::{GetParameterError, GetParameterRequest, Ssm, SsmClient};
use rusoto_s3::{Delete, DeleteObjectsRequest, ListObjectsV2Error, ListObjectsV2Request, ObjectIdentifier, S3, S3Client};

#[tokio::main] // Converts this into a synchronous function. Must not be used inside an asynchronous context.
pub async fn execute(bucket: String, parameter: String, region: Region) {
    let s3_client = S3Client::new(region.clone());
    let ssm_client = SsmClient::new(region);

    let parameter_value = match get_parameter(&ssm_client, parameter).await {
        Ok(param) => param,
        Err(e) => panic!("Could not retrieve exclusion list! {:?}", e)
    };
    
    let exclusion_set: HashSet<&str> = parameter_value
        .split(',')
        .map(|x| x.trim())
        .filter(|x| !x.is_empty())
        .map(|x| x.trim_matches('/'))
        .collect();
    
    let s3_object_keys = match get_s3_object_keys(&s3_client, &bucket).await {
        Ok(keys) => keys,
        Err(e) => panic!("Could not retrieve object keys for bucket! {:?}", e)
    };

    let mut invalid_object_identifiers: Vec<ObjectIdentifier> = Vec::new();
    for key in s3_object_keys {
        let filename = Path::new(&key).file_name().unwrap_or_default().to_str().unwrap();
        let extension = Path::new(&key).extension().unwrap_or_default().to_str().unwrap().to_lowercase();

        // Keras supports JPEG, PNG, and BMP image files
        let is_invalid = exclusion_set.contains(filename) || !(extension == "jpg" || extension == "jpeg" || extension == "png" || extension == "bmp");
        if is_invalid {
            invalid_object_identifiers.push(ObjectIdentifier { key: key.clone(), ..Default::default() });
        }
    }

    // Nothing to remove, exit
    if invalid_object_identifiers.len() == 0 {
        return;
    }

    // Note: this will fail if we have more than 1000 objects to delete, so don't dump a bunch of garbage in the bucket.
    let delete_struct = Delete { objects: invalid_object_identifiers, ..Default::default() };
    let delete_request = DeleteObjectsRequest { bucket: String::from(bucket), delete: delete_struct, ..Default::default() };
    match s3_client.delete_objects(delete_request).await {
        Ok(_) => {},
        Err(e) => panic!("{:?}", e)
    }
}

// Retrieves the keys of every object in the given bucket. Note: ListObjectsV2 only returns 1000 keys at a time
async fn get_s3_object_keys(client: &dyn S3, bucket: &str) -> Result<Vec<String>, RusotoError<ListObjectsV2Error>> {
    let mut result: Vec<String> = Vec::new();
    let mut request = Some(ListObjectsV2Request { bucket: String::from(bucket), ..Default::default() });

    loop {
        let response = match client.list_objects_v2(request.clone().unwrap()).await {
            Ok(response) => response,
            Err(e) => return Err(e)
        };

        for object in response.contents.unwrap() {
            result.push(object.key.unwrap());
        }

        if response.next_continuation_token.is_none() {
            break;
        }

        request = Some(ListObjectsV2Request { bucket: String::from(bucket), continuation_token: response.next_continuation_token, ..Default::default() })
    }    
    
    Ok(result)
}

async fn get_parameter(client: &dyn Ssm, name: String) -> Result<String, RusotoError<GetParameterError>> {
    let request = GetParameterRequest { name, ..Default::default() };

    match client.get_parameter(request).await {
        Ok(response) => Ok(response.parameter.unwrap().value.unwrap()),
        Err(e) => Err(e)
    }
}