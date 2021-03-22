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

module MetadataRecord

open System

type Label = Normal | Pneumonia | Invalid
type DataSet = Train | Test
type Cause = Normal | Virus | Bacteria | Smoking | Invalid

type MetadataRecord =
      { ImageName: string
        DataSet : DataSet
        Label: Label
        Cause: Cause
        Date: DateTime }

let labelToString label =
    match label with
    | Label.Normal -> "Normal"
    | Label.Pneumonia -> "Pneumonia"
    | Label.Invalid -> "Invalid"

let datasetToString dataset =
    match dataset with
    | Train -> "Train"
    | Test -> "Test"

let causeToString cause =
    match cause with
    | Normal -> "Normal"
    | Virus -> "Virus"
    | Bacteria -> "Bacteria"
    | Smoking -> "Smoking"
    | Invalid -> "Invalid"
