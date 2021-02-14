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

resource "aws_instance" "capstone_model" {
  ami                  = "ami-0a714e270d06489a9"
  iam_instance_profile = aws_iam_instance_profile.capstone_model.name
  instance_type        = "g4dn.4xlarge"
  security_groups      = [aws_security_group.capstone_no_ingress.name]
}
