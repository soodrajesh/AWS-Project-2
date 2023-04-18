# Define provider
provider "aws" {
  region = "us-west-2"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "subnets" {
  vpc_id = data.aws_vpc.default.id
}

data "aws_subnet" "subnets" {
  for_each = data.aws_subnet_ids.subnets.ids
  id       = each.value
}


resource "aws_api_gateway_rest_api" "my_api" {
  name = "my_api"
}

resource "aws_api_gateway_method" "my_method" {
  rest_api_id   = aws_api_gateway_rest_api.my_api.id
  resource_id   = aws_api_gateway_rest_api.my_api.root_resource_id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "my_integration" {
  rest_api_id = aws_api_gateway_rest_api.my_api.id
  resource_id = aws_api_gateway_rest_api.my_api.root_resource_id
  http_method = aws_api_gateway_method.my_method.http_method

  type = "HTTP"
  uri  = "http://${aws_lb.my-lb.dns_name}"
}

resource "aws_instance" "my_instance" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t2.micro"
  count = 1
  tags = {
  Name = "my_instance-${count.index + 1}"
  }   
}


# Create an application load balancer
resource "aws_lb" "my-lb" {
  name                       = "my-lb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.lbsg.id]
  subnets                    = data.aws_subnet_ids.subnets.ids 
  enable_deletion_protection = false

  tags = {
    Name     = "my-lb"
  }
}

# Create a target group for the ec2 instances
resource "aws_lb_target_group" "mytg" {
  name     = "mytg"
  port     = 443
  protocol = "HTTP"
  target_type = "instance"
  vpc_id   = data.aws_vpc.default.id
  health_check {
    path = "/"
  }
}

#Target group attachment 
resource "aws_lb_target_group_attachment" "tgattachment" {
  count            = length(aws_instance.my_instance.*.id) == 3 ? 3 : 0
  target_group_arn = aws_lb_target_group.mytg.arn
  target_id        = element(aws_instance.my_instance.*.id, count.index)
  port             = 80
}

#Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.my-lb.arn
  port              = "443"
  protocol          = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.mytg.arn
  }
}

#Load balancer security group
resource "aws_security_group" "lbsg" {
  name        = "Dev Load Balancer"
  vpc_id      = data.aws_vpc.default.id
}

# Create an ECS cluster to run the Fargate task
resource "aws_ecs_cluster" "my_cluster" {
  name = "my_cluster"
}

# Create a task definition for the Fargate task
resource "aws_ecs_task_definition" "my-task-def" {
  family                   = "my-task-def"
    container_definitions    = jsonencode([{
    name      = "my_container"
    image     = "my_image"
    cpu       = 256
    memory    = 512
    essential = true
  }])
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
}

resource "aws_ecs_service" "my_service" {
  name            = "my_service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.my-task-def.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups = [aws_security_group.lbsg.id]
    subnets         = data.aws_subnet_ids.subnets.ids 
  }
}


# Create policy for ECS Fargate task to run the batch processing job

data "aws_iam_policy_document" "ecs_task_execution_policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]

    effect = "Allow"
    resources = [
      "arn:aws:logs:${var.region}:${var.account_id}:log-group:/aws/ecs/fargate-events-processing:*"
    ]

  }

  statement {
    actions = [
      "dynamodb:Query",
      "dynamodb:Scan",
      "dynamodb:UpdateItem"
    ]

    effect = "Allow"
    resources = [
      aws_dynamodb_table.my_table.arn
    ]

  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject"
    ]

    effect = "Allow"
    resources = [
      "${aws_s3_bucket.my_bucket.arn}/*"
    ]

  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "fargate-events-processing-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  inline_policy {
    name   = "ecs_task_execution_policy"
    policy = data.aws_iam_policy_document.ecs_task_execution_policy.json
  }
}


#Create a Kinesis stream to receive the incoming events
resource "aws_kinesis_stream" "my_stream" {
  name             = "my_stream"
  shard_count      = 1
  retention_period = 24
}

#Create an IAM policy to allow the Lambda function and ECS Fargate task to access the Kinesis stream, S3 bucket, and DynamoDB table
resource "aws_iam_policy" "events_processing_policy" {
  name   = "events-processing-policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Action    = [
          "kinesis:DescribeStream",
          "kinesis:GetRecords",
          "kinesis:GetShardIterator",
          "kinesis:ListShards",
          "kinesis:PutRecord",
          "kinesis:PutRecords"
        ]
        Resource  = aws_kinesis_stream.my_stream.arn
      },
      {
        Effect    = "Allow"
        Action    = [
          "dynamodb:PutItem",
          "dynamodb:Query",
          "dynamodb:UpdateItem"
        ]
        Resource  = aws_dynamodb_table.my_table.arn
      },
      {
        Effect    = "Allow"
        Action    = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject"
        ]
        Resource  = [
          aws_s3_bucket.my_bucket.arn,
          "${aws_s3_bucket.my_bucket.arn}/*"
        ]
      },
      {
        Effect    = "Allow"
        Action    = "sns:Publish"
        Resource  = aws_sns_topic.my_topic.arn
      }
    ]
  })
}


resource "aws_sns_topic" "my_topic" {
  name = "my_topic"
}

resource "aws_lambda_function" "my_lambda_function" {
  function_name = "my_lambda_function"
  handler      = "index.handler"
  role         = aws_iam_role.lambda_role.arn
  runtime      = "nodejs14.x"
  filename     = "real-time-consumer.zip"
}

#Create a CloudWatch event rule to trigger the ECS Fargate task
resource "aws_cloudwatch_event_rule" "my_rule" {
  name                = "my_rule"
  description         = "Run my task at 3 am"
  schedule_expression = "cron(0 3 * * ? *)"
}

resource "aws_cloudwatch_event_target" "my_target" {
  rule      = aws_cloudwatch_event_rule.my_rule.name
  arn       = aws_ecs_task_definition.my-task-def.arn
  role_arn  = aws_iam_role.ecs_task_role.arn
  input     = jsonencode({
    containerOverrides: [{
      name: "my_container",
      command: [
        "node",
        "app.js"
      ]
    }]
  })
}

resource "aws_lambda_permission" "my_permission" {
  statement_id  = "AllowExecutionFromCloudWatch"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.my_lambda_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.my_rule.arn
}


resource "aws_dynamodb_table" "my_table" {
  name           = "my_table"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "event_id"
  attribute {
    name = "event_id"
    type = "S"
  }
}


resource "aws_iam_role" "lambda_role" {
  name = "lambda_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Create an S3 bucket to store the events
resource "aws_s3_bucket" "my_bucket" {
  bucket = "my-bucket"
  acl    = "private"

  versioning {
    enabled = true
  }
}

# Create an S3 bucket lifecycle rule to store the events
resource "aws_s3_bucket_lifecycle_configuration" "bucket-config" {
  bucket = aws_s3_bucket.my_bucket.id

  rule {
    id = "expire-old-events"
    status  = "Enabled"
    expiration {
      days = 30
    }

    filter {
      and {
        prefix = ""
      }
    }
  }
}

# Allow the Lambda function to read from the S3 bucket
resource "aws_s3_bucket_policy" "lambda_bucket_policy" {
  bucket = aws_s3_bucket.my_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = ""
        }
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.my_bucket.arn,
          "${aws_s3_bucket.my_bucket.arn}/*"
        ]
      }
    ]
  })
}


resource "aws_iam_role" "ecs_task_role" {
  name = "ecs_task_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}


resource "aws_iam_policy" "ecs_task_policy" {
  name = "ecs_task_policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = [
          "${aws_s3_bucket.my_bucket.arn}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:PutItem",
          "dynamodb:GetItem",
          "dynamodb:UpdateItem"
        ]
        Resource = [
          "${aws_dynamodb_table.my_table.arn}"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = [
          "${aws_sns_topic.my_topic.arn}"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "kinesis:PutRecord"
        ]
        Resource = [
          "${aws_kinesis_stream.my_stream.arn}"
        ]
      }
    ]
  })
}


resource "aws_iam_role_policy_attachment" "ecs_task_policy_attachment" {
  policy_arn = aws_iam_policy.ecs_task_policy.arn
  role       = aws_iam_role.ecs_task_role.name
}

# Allow the ECS task to write to the DynamoDB table
resource "aws_iam_role_policy" "fargate_dynamodb_policy" {
  name = "fargate-dynamodb-policy"
  role = aws_iam_role.ecs_task_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:BatchGetItem",
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:BatchWriteItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem",
          "dynamodb:DeleteItem"
        ]
        Resource = [
          aws_dynamodb_table.my_table.arn
        ]
      }
    ]
  })
}


resource "aws_cloudwatch_event_rule" "ecs_task_schedule" {
  name        = "ecs_task_schedule"
  description = "Schedule the ECS Fargate task to run once per day at 3 am"

  schedule_expression = "cron(0 3 * * ? *)"
}

resource "aws_cloudwatch_event_target" "ecs_task_target" {
  target_id = "ecs_task_target"

  rule      = aws_cloudwatch_event_rule.ecs_task_schedule.name
  arn       = aws_ecs_task_definition.my-task-def.arn
  role_arn  = aws_iam_role.ecs_task_role.arn
}

output "elb_dns_name" {
  value = aws_lb.my-lb.dns_name
}

output "kinesis_stream_name" {
  value = aws_kinesis_stream.my_stream.name
}

output "sns_topic_arn" {
  value = aws_sns_topic.my_topic.arn
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.my_table.name
}

output "ecs_cluster_arn" {
  value = aws_ecs_cluster.my_cluster.arn
}

output "ecs_task_definition_arn" {
  value = aws_ecs_task_definition.my-task-def.arn
}

output "lambda_function_arn" {
  value = aws_lambda_function.my_lambda_function.arn
}

output "processed_data_bucket_name" {
  value = aws_s3_bucket.my_bucket.id
}


