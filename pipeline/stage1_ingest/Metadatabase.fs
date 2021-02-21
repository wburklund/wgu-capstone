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

module Metadatabase

open Amazon.DynamoDBv2
open Amazon.DynamoDBv2.DataModel
open Amazon.DynamoDBv2.Model
open System
open System.Threading.Tasks

open MetadataRecord

type MetadatabaseRecord(filename:string, label:string, dataset:string, date:DateTime) =
    member val Filename = filename with get, set
    member val Label = label with get, set
    member val DataSet = dataset with get, set
    member val Date = date.ToString("yyyy-MM-dd") with get, set
    new() = MetadatabaseRecord(null, null, null, DateTime.MinValue)
    new(record:MetadataRecord) = MetadatabaseRecord(record.ImageName, (labelToString record.Label), (datasetToString record.DataSet), record.Date)

let get_create_metadatabase_table_request table_name =
    new CreateTableRequest(
        BillingMode = BillingMode.PAY_PER_REQUEST,
        TableName = table_name,
        AttributeDefinitions = ResizeArray<AttributeDefinition> [
            new AttributeDefinition(AttributeName = "Filename", AttributeType = ScalarAttributeType.S)
        ],
        KeySchema = ResizeArray<KeySchemaElement> [
            new KeySchemaElement(AttributeName = "Filename", KeyType = KeyType.HASH)
        ]
    )

let reset_table (client:AmazonDynamoDBClient) (create_table_request:CreateTableRequest) =
    try
        client.DeleteTableAsync(create_table_request.TableName).Wait()
    with
    | _ -> printf "Warning: Table %s did not exist" create_table_request.TableName

    // Wait for the table to be fully deleted
    Task.Delay(3000).Wait()

    client.CreateTableAsync(create_table_request).Wait()
    // NOTE: Let 10-20 seconds pass before using the reset table

let reset_metadatabase (client:AmazonDynamoDBClient) table_name =
    reset_table client (get_create_metadatabase_table_request table_name)

let load_metadatabase (client:AmazonDynamoDBClient) table_name (metadata_records:List<MetadataRecord>) =
    let context = new DynamoDBContext(client)
    let config = new DynamoDBOperationConfig()
    config.OverrideTableName <- table_name

    let write = context.CreateBatchWrite<MetadatabaseRecord>(config)
    write.AddPutItems(metadata_records |> List.map MetadatabaseRecord)

    write.ExecuteAsync().Wait()
