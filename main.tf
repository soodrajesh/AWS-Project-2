# Define variables
variable "region" {
  default = "us-west-2"
}

variable "account_id" {
  default = "094896736008"
}

# Create IAM roles
resource "aws_iam_role" "ingestion" {
  name = "ingestion_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role" "batch_consumer" {
  name = "batch_consumer_role"

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

resource "aws_iam_role" "real_time_consumer" {
  name = "real_time_consumer_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Create IAM policies
resource "aws_iam_policy" "ingestion" {
  name        = "ingestion_policy"
  description = "Allows ingesting events from public API"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "execute-api:Invoke"
        ],
        Resource = [
          "*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "batch_consumer" {
  name        = "batch_consumer_policy"
  description = "Allows batch consuming events from S3"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "s3:GetObject"
        ],
        Resource = [
          "*"
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "real_time_consumer" {
  name        = "real_time_consumer_policy"
  description = "Allows real-time consuming events from Kinesis"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "kinesis:GetShardIterator",
          "kinesis:GetRecords"
        ],
        Resource = [
          "*"
        ]
      }
    ]
  })
}

# Attach IAM policies to roles
resource "aws_iam_role_policy_attachment" "ingestion" {
  policy_arn = aws_iam_policy.ingestion.arn
  role       = aws_iam_role.ingestion.name
}

resource "aws_iam_role_policy_attachment" "batch_consumer" {
  policy_arn = aws_iam_policy.batch_consumer.arn
  role       = aws_iam_role.batch_consumer.name
}

resource "aws_iam_role_policy_attachment" "real_time_consumer" {
  policy_arn = aws_iam_policy.real_time_consumer.arn
  role       = aws_iam_role.real_time_consumer.name
}

# Create API Gateway
resource "aws_api_gateway_rest_api" "api" {
  name = "event_ingestion_api"
}

resource "aws_api_gateway_resource" "resource" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "{proxy+}"
}

# Create an API Gateway REST API and deploy it
resource "aws_api_gateway_rest_api" "events_api" {
  name        = "events-api"
  description = "API for ingesting events"
}

resource "aws_api_gateway_resource" "events_resource" {
  rest_api_id = aws_api_gateway_rest_api.events_api.id
  parent_id   = aws_api_gateway_rest_api.events_api.root_resource_id
  path_part   = "events"
}

resource "aws_api_gateway_method" "events_method" {
  rest_api_id   = aws_api_gateway_rest_api.events_api.id
  resource_id   = aws_api_gateway_resource.events_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "events_integration" {
  rest_api_id          = aws_api_gateway_rest_api.events_api.id
  resource_id          = aws_api_gateway_resource.events_resource.id
  http_method          = aws_api_gateway_method.events_method.http_method
  type                 = "AWS_PROXY"
  uri                  = aws_lambda_function.real_time_consumer.invoke_arn
  integration_http_method = "POST"
}

# resource "aws_api_gateway_deployment" "deployment" {
#   rest_api_id = aws_api_gateway_rest_api.events_api.id
#   stage_name  = "prod"
# }

# Create an S3 bucket to store events
resource "aws_s3_bucket" "events_bucket" {
  bucket_prefix = "events-bucket-s3"
  acl           = "private"
  lifecycle_rule {
    id      = "delete-logs"
    prefix  = "logs/"
    enabled = true

    expiration {
      days = 30

#   tags = {
#     Name        = "events-bucket"
#     Environment = "production"
#    }
  }
 }
}


# Enable server-side encryption on the S3 bucket
resource "aws_s3_bucket_server_side_encryption_configuration" "events_bucket_encryption" {
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }

  bucket = aws_s3_bucket.events_bucket.id
}

# # Create a DynamoDB table to store events
# resource "aws_dynamodb_table" "events_table" {
#   name           = "events-table"
#   billing_mode   = "PAY_PER_REQUEST"
#   hash_key       = "orderReference"
#   attribute {
#     name = "orderReference"
#     type = "S"
#   }
# #   attribute {
# #     name = "advertiserId"
# #     type = "N"
# #   }
# #   attribute {
# #     name = "totalamount"
# #     type = "N"
# #   }
# #   attribute {
# #     name = "currencyCode"
# #     type = "S"
# #   }

#   tags = {
#     Name        = "events-table"
#     Environment = "production"
#   }
# }

# # Create an IAM role for the near-real-time consumer
# resource "aws_iam_role" "real_time_consumer" {
#   name = "real-time-consumer-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Principal = {
#           Service = "lambda.amazonaws.com"
#         }
#         Action = "sts:AssumeRole"
#       }
#     ]
#   })
# }

# Attach an IAM policy to the role to allow access to CloudWatch Logs
resource "aws_iam_role_policy_attachment" "real_time_consumer_logs" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.real_time_consumer.name
}

# Create a Lambda function for the near-real-time consumer
resource "aws_lambda_function" "real_time_consumer" {
  function_name = "real-time-consumer"
  handler      = "index.handler"
  runtime      = "nodejs14.x"
  timeout      = 60
  memory_size  = 128
  role         = aws_iam_role.real_time_consumer.arn
  filename     = "real-time-consumer.zip"

  environment {
    variables = {
      BATCH_JOB_QUEUE_URL = aws_sqs_queue.batch_job_queue.url
    }
  }

  # Create a new version of the function every time the code is updated
  lifecycle {
    create_before_destroy = true
  }

  # Specify the function's source code
  source_code_hash = filebase64sha256("real-time-consumer.zip")
}

# Create a permission that allows the API Gateway to invoke the Lambda function
resource "aws_lambda_permission" "api_gateway_invoke_real_time_consumer" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.real_time_consumer.function_name
  principal     = "apigateway.amazonaws.com"

  # Allow the API Gateway to invoke the Lambda function for any resource/method combination
  source_arn = "${aws_api_gateway_deployment.deployment.execution_arn}/*/*/*"
}

######

resource "aws_dynamodb_table" "events" {
  name           = "events"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "advertiserId"
  range_key      = "orderReference"

  attribute {
    name = "advertiserId"
    type = "N"
  }

  attribute {
    name = "orderReference"
    type = "S"
  }
}


# resource "aws_api_gateway_rest_api" "api" {
#   name = "order-events-api"
# }

resource "aws_api_gateway_resource" "root" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "{advertiserId}"
}

resource "aws_api_gateway_method" "post" {
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.root.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.root.id
  http_method             = aws_api_gateway_method.post.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.real_time_consumer.arn
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = "prod"

  depends_on = [
    aws_api_gateway_integration.integration,
  ]
}

output "api_gateway_endpoint" {
  value = aws_api_gateway_deployment.deployment.invoke_url
}


resource "aws_lambda_permission" "dynamodb" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.real_time_consumer.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_deployment.deployment.execution_arn}/*/*/advertiserId/*"
}

resource "aws_iam_policy" "events" {
  name = "dynamodb-table-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "AllowLambdaToPutItem"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
        Action = [
          "dynamodb:PutItem",
          "dynamodb:BatchWriteItem"
        ]
        Resource = aws_dynamodb_table.events.arn
      },
      {
        Sid = "AllowBatchConsumerToScanTable"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${var.account_id}:role/batch_consumer"
        }
        Action = [
          "dynamodb:Scan",
          "dynamodb:Query"
        ]
        Resource = aws_dynamodb_table.events.arn
      }
    ]
  })
}

# Define the event queue configuration
resource "aws_sqs_queue" "batch_job_queue" {
  name                = "batch_job_queue"
  delay_seconds       = 0
  max_message_size    = "262144"
  message_retention_seconds = "1209600"
}


# Grant SNS permissions to send messages to the event queue
resource "aws_sqs_queue_policy" "batch_job_queue" {
  queue_url = "${aws_sqs_queue.batch_job_queue.id}"

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "sns_policy",
  "Statement": [
    {
      "Sid": "sns_send",
      "Effect": "Allow",
      "Principal": "*",
      "Action": "sqs:SendMessage",
      "Resource": "${aws_sqs_queue.batch_job_queue.arn}",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sns_topic.event_topic.arn}"
        }
      }
    }
  ]
}
POLICY
}


# Create an SNS topic to handle event notifications
resource "aws_sns_topic" "event_topic" {
  name = "my-events-topic"
}

# Create an SNS subscription to send messages to the event queue
resource "aws_sns_topic_subscription" "event_topic" {
  topic_arn = aws_sns_topic.event_topic.arn
  protocol  = "sqs"
  endpoint  = aws_sqs_queue.batch_job_queue.arn
}
