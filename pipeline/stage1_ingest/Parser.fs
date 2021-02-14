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

module Parser

open System.IO
open MetadataRecord
open Amazon.S3
open System

let private lines_of_s3_file (bucket:string) (key:string) =
    seq { use client = new AmazonS3Client()
          use getResponse = client.GetObjectAsync(bucket, key).Result
          use reader = new StreamReader(getResponse.ResponseStream)
          while not reader.EndOfStream do
          yield reader.ReadLine() };;

let private parse_metadata_record (record:string) : MetadataRecord =
    let tokens = record.Split ','

    let image_name = tokens.[1]
    
    let dataset =
        match tokens.[3] with
        | "TRAIN" -> DataSet.Train
        | "TEST" -> DataSet.Test
        | other -> failwithf "Invalid dataset '%s' in metadata!" other

    let label =
        match tokens.[2] with
        | "Normal" -> Label.Normal
        | "Pnemonia" -> Label.Pneumonia
        | _ -> Label.Invalid
    if label = Invalid then printfn "Invalid label (%s, %s) found for image '%s'. Skipping..." tokens.[2] tokens.[5] image_name

    let date = DateTime.Parse tokens.[6]

    { ImageName = image_name; DataSet = dataset; Label = label; Date = date }

let parse_metadata_csv bucket key =
    lines_of_s3_file bucket key
    |> Seq.skip 1
    |> Seq.map parse_metadata_record
    |> Seq.filter (fun record -> record.Label <> Invalid)
    |> List.ofSeq
