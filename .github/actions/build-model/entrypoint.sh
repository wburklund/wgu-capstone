#!/bin/sh
#
#  WGU Capstone Project
#  Copyright (C) 2021 Will Burklund
#
#  This program is free software: you can redistribute it and/or modify
#  it under the terms of the GNU Affero General Public License as published by
#  the Free Software Foundation, either version 3 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU Affero General Public License for more details.
#
#  You should have received a copy of the GNU Affero General Public License
#  along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

mkdir -p artifacts/stage3_model_run
cd /github/workspace/pipeline/stage3_model/

cp run/* /github/workspace/artifacts/stage3_model_run/
zip -j /github/workspace/artifacts/stage3_model_status.zip status/index.js
zip -j /github/workspace/artifacts/stage3_model_trigger.zip trigger/lambda_function.rb
 