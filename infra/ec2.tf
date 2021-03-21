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

resource "aws_autoscaling_group" "capstone_api" {
  availability_zones   = ["us-east-2a"]
  desired_capacity     = 1
  max_size             = 1
  min_size             = 1
  name                 = "capstone"
  launch_configuration = aws_launch_configuration.capstone_api.name

  tag {
    key                 = "AmazonECSManaged"
    value               = ""
    propagate_at_launch = true
  }
}

resource "aws_instance" "capstone_model_run" {
  ami                  = "ami-0a714e270d06489a9"
  iam_instance_profile = aws_iam_instance_profile.capstone_model_run.name
  instance_type        = "g4dn.4xlarge"
  security_groups      = [aws_security_group.capstone_no_ingress.name]
}

resource "aws_launch_configuration" "capstone_api" {
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.capstone_api.name
  image_id                    = "ami-02ef98ccecbf47e86"
  instance_type               = "t3.small"
  name                        = "capstone_api"
  security_groups             = [aws_security_group.capstone_api.id]
  user_data                   = file("assets/capstone_api_user_data.sh")
}

resource "aws_security_group" "capstone_api" {
  name = "capstone_api"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "capstone_no_ingress" {
  name = "capstone_no_ingress"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 1
    to_port     = 1
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/32"]
  }
}

resource "null_resource" "stop_model_run_instance" {
  depends_on = [
    aws_instance.capstone_model_run
  ]

  provisioner "local-exec" {
    command    = "aws ec2 stop-instances --instance-ids ${aws_instance.capstone_model_run.id} --region ${local.region}"
    on_failure = fail
  }

  triggers = {
    new_instance = aws_instance.capstone_model_run.id
  }
}