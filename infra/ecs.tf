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

resource "aws_ecs_capacity_provider" "capstone_api" {
  name = "capstone_api"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.capstone_api.arn
  }
}

resource "aws_ecs_cluster" "capstone_api" {
  capacity_providers = [aws_ecs_capacity_provider.capstone_api.name]
  name               = "capstone_api"
}

resource "aws_ecs_service" "capstone_api" {
  cluster               = aws_ecs_cluster.capstone_api.name
  desired_count         = 1
  name                  = "capstone_api"
  task_definition       = "${aws_ecs_task_definition.capstone_api.family}:${aws_ecs_task_definition.capstone_api.revision}"
  wait_for_steady_state = true
}

resource "aws_ecs_task_definition" "capstone_api" {
  family                = "capstone_api"
  task_role_arn         = aws_iam_role.capstone_api.arn
  container_definitions = <<EOF
[
  {
    "environment": [
      {
        "name": "API_KEY",
        "value": "${var.api_key}"
      },
      {
        "name": "AWS_DEFAULT_REGION",
        "value": "${local.region}"
      }
    ],
    "entryPoint": [ "python3" ],
    "name": "capstone_api",
    "command": [ "application.py" ],
    "image": "${local.account_id}.dkr.ecr.${local.region}.amazonaws.com/capstone:latest",
    "cpu": 0,
    "memoryReservation": 900,
    "essential": true,
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ],
    "workingDirectory": "/app"
  }
]
EOF
}
