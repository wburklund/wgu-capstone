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

use lambda_runtime::{error::HandlerError, lambda, Context};
use log::LevelFilter;
use rusoto_core::Region;
use serde_derive::Serialize;
use simple_logger::SimpleLogger;
use std::env;
use std::error::Error;

mod execute;

#[allow(non_snake_case)]
#[derive(Serialize, Clone)]
struct LambdaOutput {
    statusCode: usize,
    message: String,
}

fn main() -> Result<(), &'static dyn Error> {
    match SimpleLogger::new().with_level(LevelFilter::Info).init() {
        Ok(_) => {},
        Err(e) => panic!("{:?}", e)
    };

    lambda!(handler);

    Ok(())
}

fn handler(_: String, _: Context) -> Result<LambdaOutput, HandlerError> {
    let _region = env::var("AWS_REGION").unwrap();                              // This is read silently by rusoto_core::Region::default() (and set automatically by AWS Lambda)
    let bucket = env::var("S3_BUCKET").unwrap();
    let parameter = env::var("EXCLUSION_LIST_PARAMETER").unwrap();

    execute::execute(bucket, parameter, Region::default());

    Ok(LambdaOutput {
        statusCode: 200,
        message: format!("Clean successful."),
    })
}