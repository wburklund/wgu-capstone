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

# Contract: current directory contains the latest modeling code, s3://capstone-model-input contains the latest modeling input data
INPUT_DIR="../input"
OUTPUT_DIR="../output"

# Exit on error
set -e

# Ensure symbolic links exist for cross-user Python execution
ln -nsf /home/ec2-user/anaconda3 ~/anaconda3
ln -nsf /home/ec2-user/.dl_binaries ~/.dl_binaries

# Ensure working directories exist
mkdir -p $INPUT_DIR
mkdir -p $OUTPUT_DIR

# Populate input directory, clearing any existing data
aws s3 sync s3://capstone-model-input $INPUT_DIR --delete

# Clear output directory if it isn't empty
if [ "$(ls -A $OUTPUT_DIR)" ]; then
    rm -r $OUTPUT_DIR/*
fi

# Activate virtual environment
source ../anaconda3/bin/activate tensorflow2_latest_p37

# Train deep learning model
INPUT_DIR=$INPUT_DIR OUTPUT_DIR=$OUTPUT_DIR python main.py

# Output modeling results, clearing any existing data
aws s3 sync $OUTPUT_DIR s3://capstone-model-output --delete
