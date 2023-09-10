####################################################
# クラスター
####################################################
resource "aws_ecs_cluster" "terafform_cluster" {
  name = "terraform_cluster"
}

resource "aws_ecs_cluster_capacity_providers" "provider" {
  cluster_name       = aws_ecs_cluster.terafform_cluster.name
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
}

####################################################
# Cloud Watch Log Group
####################################################
resource "aws_cloudwatch_log_group" "nginx" {
  # name              = "/ecs/logs/terraform/nginx"
  # name              = "/ecs/logs/terraform/rails"
  name              = "/ecs/"
  retention_in_days = 1
}

# resource "aws_cloudwatch_log_group" "rails" {
#   name              = "/ecs/"
#   retention_in_days = 1
# }

####################################################
# IAM
####################################################
# ECS
resource "aws_iam_role" "ecs_task_execution_role" {
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Sid = ""
      },
    ]
  })
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy",
    "${aws_iam_policy.ecs_to_ecr_policy.arn}",
    "${aws_iam_policy.ssm_policy.arn}",
    "${aws_iam_policy.ecs_exec_role.arn}"
  ]
  description = "Allows ECS tasks to call AWS services on your behalf."
  name        = "ecsTaskExecutionRole"
  path        = "/"
}

# ECR
resource "aws_iam_policy" "ecs_to_ecr_policy" {
  name = "ECS-ECR-Communication-Policy"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
        ],
        Resource = "*"
      }
    ]
  })
}

# SSM
resource "aws_iam_policy" "ssm_policy" {
  name = "SSM-Policy"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "ssmmessages:OpenDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:CreateControlChannel",
          "ssm:GetParameters",
          "kms:Decrypt"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "ecs_exec_role" {
  name = "ecs-exec-role"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = [
          "ecs:ExecuteCommand",
          "ssm:StartSession",
          "ecs:DescribeTasks"
        ],
        Resource = "*"
      }
    ]
  })
}


####################################################
# タスク定義
####################################################
# Nginx（疎通確認用）
# resource "aws_ecs_task_definition" "main" {
#   family                   = "nginx"
#   container_definitions    = file("./task-definition/nginx.json")
#   cpu                      = 256
#   memory                   = 512
#   network_mode             = "awsvpc"
#   execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
#   requires_compatibilities = ["FARGATE"]
#   tags = {
#     "Name" = "terraform"
#   }
# }

resource "aws_ecs_task_definition" "main" {
  family                   = "pairly-backend"
  # container_definitions    = file("./task-definition/main.json")
  container_definitions = jsonencode([{
    name = "pairly-backend",
    image = "075983717898.dkr.ecr.ap-northeast-1.amazonaws.com/pairly-backend",
    essential = true,
    portMappings = [
        {
            name = "pairly-backend-80-tcp",
            containerPort = 80,
            hostPort = 80,
            protocol = "tcp",
            appProtocol = "http",
        }
    ],
    "environment": [
        {
            name = "RAILS_ENV",
            value = "production",
        },
        {
            name = "RAILS_SERVE_STATIC_FILES",
            value = "true",
        },
        {
            name = "RAILS_LOG_TO_STDOUT",
            value = "true",
        },
        {
            name = "FIREBASE_AUTH_DOMAIN",
            value = "pairly-8c80b.firebaseapp.com"
        },
        {
            name = "FIREBASE_PROJECT_ID",
            value = "pairly-8c80b"
        }
    ],
    secrets = [
        {
            name = "SECRET_KEY_BASE",
            valueFrom = "/pairly-backend/rails/secret-key-base",
        },
        {
            name = "RAILS_MASTER_KEY",
            valueFrom = "/pairly-backend/rails/master-key",
        },
        {
            name = "DB_HOST",
            valueFrom = "/pairly-backend/db/host",
        },
        {
            name = "DB_USERNAME",
            valueFrom = "/pairly-backend/db/username",
        },
        {
            name = "DB_PASSWORD",
            valueFrom = "/pairly-backend/db/password",
        },
        {
            name = "FIREBASE_API_KEY",
            valueFrom = "/pairly-backend/firebase/api-key",
        }

    ],
    LogConfiguration = {
        logDriver = "awslogs",
        options = {
            awslogs-group = "/ecs/",
            awslogs-region = "ap-northeast-1",
            awslogs-stream-prefix = "terraform",
        }
    }
  }])
  cpu                       = 256
  memory                    = 512
  network_mode              = "awsvpc"
  task_role_arn = aws_iam_role.ecs_task_execution_role.arn
  execution_role_arn        = aws_iam_role.ecs_task_execution_role.arn
  requires_compatibilities  = ["FARGATE"]
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  tags = {
    "Name" = "terraform"
  }
}

####################################################
# サービス
####################################################
resource "aws_ecs_service" "tf_ecs_service" {
  name = "terraform_ecs"
  cluster       = aws_ecs_cluster.terafform_cluster.id
  task_definition = aws_ecs_task_definition.main.arn

  # capacity_provider_strategy {
  #   capacity_provider = "FARGATE"
  #   base              = 1
  #   weight            = 1
  # }

  capacity_provider_strategy {
    capacity_provider = "FARGATE_SPOT"
    base              = 1
    weight            = 1
  }
  
  desired_count = 1

  network_configuration {
    subnets = [
      aws_subnet.app_public_subnet_1a.id,
      aws_subnet.app_public_subnet_1c.id
    ]
    security_groups  = [aws_security_group.app_sg.id]
    assign_public_ip = true # IPアドレス付与
  }


  tags = {
    "Name" = "terraform"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.alb_target_group.arn
    # container_name   = "nginx"
    container_name   = "pairly-backend"
    container_port   = 80
  }

  # lifecycle {
  #   ignore_changes = [
  #     task_definition
  #   ]
  # }

  health_check_grace_period_seconds = 2147483647
}
