data "aws_ecs_task_definition" "capstone_api" {
    task_definition = "console-sample-app-static"
}

resource "aws_ecs_capacity_provider" "capstone_api" {
    name = "capstone_api"

    auto_scaling_group_provider {
        auto_scaling_group_arn = aws_autoscaling_group.capstone_api.arn
    }
}

resource "aws_ecs_cluster" "capstone_api" {
    capacity_providers = [aws_ecs_capacity_provider.capstone_api.name]
    name = "capstone_api"
}

resource "aws_ecs_service" "capstone_api" {
    cluster = aws_ecs_cluster.capstone_api.name
    desired_count = 1
    name = "capstone_api"
    task_definition = "${data.aws_ecs_task_definition.capstone_api.family}:${data.aws_ecs_task_definition.capstone_api.revision}"
}
