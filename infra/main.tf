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

provider "aws" {
  region = "us-east-2"

  assume_role {
    role_arn = "arn:aws:iam::551524640723:role/terraform"
  }
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"

  assume_role {
    role_arn = "arn:aws:iam::551524640723:role/terraform"
  }
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
}

variable "api_key" {
  sensitive = true
  type      = string
}

variable "upload_directory" {
  default = "../application/web/build/"
}

variable "mime_types" {
  default = {
    css   = "text/css"
    eot   = "application/vnd.ms-fontobject"
    htm   = "text/html"
    html  = "text/html"
    jpg   = "image/jpeg"
    js    = "application/javascript"
    json  = "application/json"
    map   = "application/javascript"
    png   = "image/png"
    svg   = "image/svg+xml"
    ttf   = "font/ttf"
    txt   = "text/plain"
    woff  = "application/x-font-woff"
    woff2 = "font/woff2"
  }
}