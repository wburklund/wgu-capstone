(*
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
*)

module Program

open MetadataRecord
open Metadatabase
open Parser
open System
open System.Threading.Tasks
open Amazon.S3
open Amazon.S3.Model
open Amazon.DynamoDBv2

let dataStoreBucket = Environment.GetEnvironmentVariable("dataStoreBucket")
let metadataObjectKey = Environment.GetEnvironmentVariable("metadataObjectKey")
let sourceKeyPrefix = Environment.GetEnvironmentVariable("sourceKeyPrefix")
let destinationBucket = Environment.GetEnvironmentVariable("destinationBucket")
let metadatabaseTableName = Environment.GetEnvironmentVariable("metadatabaseTableName")

let get_source_path (record:MetadataRecord) =
    let dataset_directory =
        match record.DataSet with
        | DataSet.Train -> "train"
        | DataSet.Test -> "test"

    $"{sourceKeyPrefix}/{dataset_directory}/{record.ImageName}"

let get_destination_path (record:MetadataRecord) =
    let dataset_directory =
        match record.DataSet with
        | DataSet.Train -> "Train"
        | DataSet.Test -> "Test"

    let label_directory = 
        match (record.DataSet, record.Label) with
        | (_, Label.Invalid) -> failwithf "Internal error: get_destination_path called with invalid label"
        | (DataSet.Train, Label.Normal) -> "Normal"
        | (DataSet.Train, Label.Pneumonia) -> "Pneumonia"
        | (DataSet.Test, _) -> "Unlabeled"

    $"{dataset_directory}/{label_directory}/{record.ImageName}"

let copy_file_block (metadata:List<MetadataRecord>) =
    let client = new AmazonS3Client()
    let requests = metadata
                   |> List.map (fun x -> get_source_path x, get_destination_path x)
                   |> List.map (fun (x, y) -> client.CopyObjectAsync(dataStoreBucket, x, destinationBucket, y))
                   |> ResizeArray

    Task.WhenAll(requests.ToArray()).Wait()
    client.Dispose()

let empty_bucket bucket =
    let client = new AmazonS3Client()
    let firstRequest = new ListObjectsV2Request()
    firstRequest.BucketName <- bucket

    // We can only delete 1000 objects at a time
    let mutable listResponse = client.ListObjectsV2Async(firstRequest).Result

    while listResponse.KeyCount > 0 do
        let keys = (List.ofSeq listResponse.S3Objects
                    |> List.map (fun x -> x.Key)
                    |> Seq.toList)

        let deleteRequest = new DeleteObjectsRequest()
        deleteRequest.BucketName <- bucket
        for key in keys do
            deleteRequest.AddKey key
        let _ = client.DeleteObjectsAsync(deleteRequest).Result
                 
        let nextRequest = new ListObjectsV2Request()
        nextRequest.BucketName <- bucket
        listResponse <- client.ListObjectsV2Async(nextRequest).Result
    client.Dispose()

let main =
    let client = new AmazonDynamoDBClient()
    reset_metadatabase client metadatabaseTableName
    empty_bucket destinationBucket
    let metadata = parse_metadata_csv dataStoreBucket metadataObjectKey

    // Transfer S3 files in parallel, with a 500-file block size
    // This greatly improves performance without crashing the Lambda
    // Scaling beyond 100,000 files is possible with S3 Batch Operations
    let mutable remaining_metadata = metadata
    while remaining_metadata.Length > 500 do
        let current_block = remaining_metadata.[0..499]
        copy_file_block current_block
        remaining_metadata <- remaining_metadata.[500..]
    copy_file_block remaining_metadata

    load_metadatabase client metadatabaseTableName metadata
    
    client.Dispose()
    0