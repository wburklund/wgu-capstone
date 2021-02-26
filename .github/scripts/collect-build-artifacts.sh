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

mkdir -p artifacts

if [ -d "stage1_ingest" ]; then
    mv stage1_ingest/* artifacts/
fi
if [ -d "stage2_clean" ]; then
    mv stage2_clean/* artifacts/
fi
if [ -d "stage3_model" ]; then
    mv stage3_model/* artifacts/
fi
if [ -d "stage4_test" ]; then
    mv stage4_test/* artifacts/
fi
if [ -d "stage5_deploy" ]; then
    mv stage5_deploy/* artifacts/
fi
exit 0
