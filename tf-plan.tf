[ec2-user@ip-172-31-25-83 code]$ terraform plan
data.aws_vpc.default: Reading...
data.aws_vpc.default: Read complete after 0s [id=vpc-0bd5ca5c81f3fb195]
data.aws_subnet_ids.subnets: Reading...
data.aws_subnet_ids.subnets: Read complete after 0s [id=vpc-0bd5ca5c81f3fb195]
data.aws_subnet.subnets["subnet-058913b23d9c72eb1"]: Reading...
data.aws_subnet.subnets["subnet-092317f239795c6c0"]: Reading...
data.aws_subnet.subnets["subnet-0b05e8e772705b1eb"]: Reading...
data.aws_subnet.subnets["subnet-049ac40c7fa73e691"]: Reading...
data.aws_subnet.subnets["subnet-049ac40c7fa73e691"]: Read complete after 0s [id=subnet-049ac40c7fa73e691]
data.aws_subnet.subnets["subnet-058913b23d9c72eb1"]: Read complete after 1s [id=subnet-058913b23d9c72eb1]
data.aws_subnet.subnets["subnet-0b05e8e772705b1eb"]: Read complete after 1s [id=subnet-0b05e8e772705b1eb]
data.aws_subnet.subnets["subnet-092317f239795c6c0"]: Read complete after 1s [id=subnet-092317f239795c6c0]

Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:
  + create
 <= read (data resources)

Terraform will perform the following actions:

  # data.aws_iam_policy_document.ecs_task_execution_policy will be read during apply
  # (config refers to values not yet known)
 <= data "aws_iam_policy_document" "ecs_task_execution_policy" {
      + id   = (known after apply)
      + json = (known after apply)

      + statement {
          + actions   = [
              + "logs:CreateLogStream",
              + "logs:PutLogEvents",
            ]
          + effect    = "Allow"
          + resources = [
              + "arn:aws:logs:us-west-2:1234567890:log-group:/aws/ecs/fargate-events-processing:*",
            ]
        }
      + statement {
          + actions   = [
              + "dynamodb:Query",
              + "dynamodb:Scan",
              + "dynamodb:UpdateItem",
            ]
          + effect    = "Allow"
          + resources = [
              + (known after apply),
            ]
        }
      + statement {
          + actions   = [
              + "s3:GetObject",
              + "s3:PutObject",
            ]
          + effect    = "Allow"
          + resources = [
              + (known after apply),
            ]
        }
    }

  # aws_api_gateway_integration.my_integration will be created
  + resource "aws_api_gateway_integration" "my_integration" {
      + cache_namespace      = (known after apply)
      + connection_type      = "INTERNET"
      + http_method          = "POST"
      + id                   = (known after apply)
      + passthrough_behavior = (known after apply)
      + resource_id          = (known after apply)
      + rest_api_id          = (known after apply)
      + timeout_milliseconds = 29000
      + type                 = "HTTP"
      + uri                  = (known after apply)
    }

  # aws_api_gateway_method.my_method will be created
  + resource "aws_api_gateway_method" "my_method" {
      + api_key_required = false
      + authorization    = "NONE"
      + http_method      = "POST"
      + id               = (known after apply)
      + resource_id      = (known after apply)
      + rest_api_id      = (known after apply)
    }

  # aws_api_gateway_rest_api.my_api will be created
  + resource "aws_api_gateway_rest_api" "my_api" {
      + api_key_source               = (known after apply)
      + arn                          = (known after apply)
      + binary_media_types           = (known after apply)
      + created_date                 = (known after apply)
      + description                  = (known after apply)
      + disable_execute_api_endpoint = (known after apply)
      + execution_arn                = (known after apply)
      + id                           = (known after apply)
      + minimum_compression_size     = -1
      + name                         = "my_api"
      + policy                       = (known after apply)
      + root_resource_id             = (known after apply)
      + tags_all                     = (known after apply)
    }

  # aws_cloudwatch_event_rule.ecs_task_schedule will be created
  + resource "aws_cloudwatch_event_rule" "ecs_task_schedule" {
      + arn                 = (known after apply)
      + description         = "Schedule the ECS Fargate task to run once per day at 3 am"
      + event_bus_name      = "default"
      + id                  = (known after apply)
      + is_enabled          = true
      + name                = "ecs_task_schedule"
      + name_prefix         = (known after apply)
      + schedule_expression = "cron(0 3 * * ? *)"
      + tags_all            = (known after apply)
    }

  # aws_cloudwatch_event_rule.my_rule will be created
  + resource "aws_cloudwatch_event_rule" "my_rule" {
      + arn                 = (known after apply)
      + description         = "Run my task at 3 am"
      + event_bus_name      = "default"
      + id                  = (known after apply)
      + is_enabled          = true
      + name                = "my_rule"
      + name_prefix         = (known after apply)
      + schedule_expression = "cron(0 3 * * ? *)"
      + tags_all            = (known after apply)
    }

  # aws_cloudwatch_event_target.ecs_task_target will be created
  + resource "aws_cloudwatch_event_target" "ecs_task_target" {
      + arn            = (known after apply)
      + event_bus_name = "default"
      + id             = (known after apply)
      + role_arn       = (known after apply)
      + rule           = "ecs_task_schedule"
      + target_id      = "ecs_task_target"
    }

  # aws_cloudwatch_event_target.my_target will be created
  + resource "aws_cloudwatch_event_target" "my_target" {
      + arn            = (known after apply)
      + event_bus_name = "default"
      + id             = (known after apply)
      + input          = jsonencode(
            {
              + containerOverrides = [
                  + {
                      + command = [
                          + "node",
                          + "app.js",
                        ]
                      + name    = "my_container"
                    },
                ]
            }
        )
      + role_arn       = (known after apply)
      + rule           = "my_rule"
      + target_id      = (known after apply)
    }

  # aws_dynamodb_table.my_table will be created
  + resource "aws_dynamodb_table" "my_table" {
      + arn              = (known after apply)
      + billing_mode     = "PAY_PER_REQUEST"
      + hash_key         = "event_id"
      + id               = (known after apply)
      + name             = "my_table"
      + read_capacity    = (known after apply)
      + stream_arn       = (known after apply)
      + stream_label     = (known after apply)
      + stream_view_type = (known after apply)
      + tags_all         = (known after apply)
      + write_capacity   = (known after apply)

      + attribute {
          + name = "event_id"
          + type = "S"
        }
    }

  # aws_ecs_cluster.my_cluster will be created
  + resource "aws_ecs_cluster" "my_cluster" {
      + arn                = (known after apply)
      + capacity_providers = (known after apply)
      + id                 = (known after apply)
      + name               = "my_cluster"
      + tags_all           = (known after apply)
    }

  # aws_ecs_service.my_service will be created
  + resource "aws_ecs_service" "my_service" {
      + cluster                            = (known after apply)
      + deployment_maximum_percent         = 200
      + deployment_minimum_healthy_percent = 100
      + desired_count                      = 1
      + enable_ecs_managed_tags            = false
      + enable_execute_command             = false
      + iam_role                           = (known after apply)
      + id                                 = (known after apply)
      + launch_type                        = "FARGATE"
      + name                               = "my_service"
      + platform_version                   = (known after apply)
      + scheduling_strategy                = "REPLICA"
      + tags_all                           = (known after apply)
      + task_definition                    = (known after apply)
      + triggers                           = (known after apply)
      + wait_for_steady_state              = false

      + network_configuration {
          + assign_public_ip = false
          + security_groups  = (known after apply)
          + subnets          = [
              + "subnet-049ac40c7fa73e691",
              + "subnet-058913b23d9c72eb1",
              + "subnet-092317f239795c6c0",
              + "subnet-0b05e8e772705b1eb",
            ]
        }
    }

  # aws_ecs_task_definition.my-task-def will be created
  + resource "aws_ecs_task_definition" "my-task-def" {
      + arn                      = (known after apply)
      + arn_without_revision     = (known after apply)
      + container_definitions    = jsonencode(
            [
              + {
                  + cpu       = 256
                  + essential = true
                  + image     = "my_image"
                  + memory    = 512
                  + name      = "my_container"
                },
            ]
        )
      + family                   = "my-task-def"
      + id                       = (known after apply)
      + network_mode             = "awsvpc"
      + requires_compatibilities = [
          + "FARGATE",
        ]
      + revision                 = (known after apply)
      + skip_destroy             = false
      + tags_all                 = (known after apply)
    }

  # aws_iam_policy.ecs_task_policy will be created
  + resource "aws_iam_policy" "ecs_task_policy" {
      + arn         = (known after apply)
      + id          = (known after apply)
      + name        = "ecs_task_policy"
      + name_prefix = (known after apply)
      + path        = "/"
      + policy      = (known after apply)
      + policy_id   = (known after apply)
      + tags_all    = (known after apply)
    }

  # aws_iam_policy.events_processing_policy will be created
  + resource "aws_iam_policy" "events_processing_policy" {
      + arn         = (known after apply)
      + id          = (known after apply)
      + name        = "events-processing-policy"
      + name_prefix = (known after apply)
      + path        = "/"
      + policy      = (known after apply)
      + policy_id   = (known after apply)
      + tags_all    = (known after apply)
    }

  # aws_iam_role.ecs_task_execution_role will be created
  + resource "aws_iam_role" "ecs_task_execution_role" {
      + arn                   = (known after apply)
      + assume_role_policy    = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "sts:AssumeRole"
                      + Effect    = "Allow"
                      + Principal = {
                          + Service = "ecs-tasks.amazonaws.com"
                        }
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + create_date           = (known after apply)
      + force_detach_policies = false
      + id                    = (known after apply)
      + managed_policy_arns   = (known after apply)
      + max_session_duration  = 3600
      + name                  = "fargate-events-processing-role"
      + name_prefix           = (known after apply)
      + path                  = "/"
      + tags_all              = (known after apply)
      + unique_id             = (known after apply)

      + inline_policy {
          + name   = "ecs_task_execution_policy"
          + policy = (known after apply)
        }
    }

  # aws_iam_role.ecs_task_role will be created
  + resource "aws_iam_role" "ecs_task_role" {
      + arn                   = (known after apply)
      + assume_role_policy    = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "sts:AssumeRole"
                      + Effect    = "Allow"
                      + Principal = {
                          + Service = "ecs-tasks.amazonaws.com"
                        }
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + create_date           = (known after apply)
      + force_detach_policies = false
      + id                    = (known after apply)
      + managed_policy_arns   = (known after apply)
      + max_session_duration  = 3600
      + name                  = "ecs_task_role"
      + name_prefix           = (known after apply)
      + path                  = "/"
      + tags_all              = (known after apply)
      + unique_id             = (known after apply)
    }

  # aws_iam_role.lambda_role will be created
  + resource "aws_iam_role" "lambda_role" {
      + arn                   = (known after apply)
      + assume_role_policy    = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "sts:AssumeRole"
                      + Effect    = "Allow"
                      + Principal = {
                          + Service = "lambda.amazonaws.com"
                        }
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
      + create_date           = (known after apply)
      + force_detach_policies = false
      + id                    = (known after apply)
      + managed_policy_arns   = (known after apply)
      + max_session_duration  = 3600
      + name                  = "lambda_role"
      + name_prefix           = (known after apply)
      + path                  = "/"
      + tags_all              = (known after apply)
      + unique_id             = (known after apply)
    }

  # aws_iam_role_policy.fargate_dynamodb_policy will be created
  + resource "aws_iam_role_policy" "fargate_dynamodb_policy" {
      + id     = (known after apply)
      + name   = "fargate-dynamodb-policy"
      + policy = (known after apply)
      + role   = (known after apply)
    }

  # aws_iam_role_policy_attachment.ecs_task_policy_attachment will be created
  + resource "aws_iam_role_policy_attachment" "ecs_task_policy_attachment" {
      + id         = (known after apply)
      + policy_arn = (known after apply)
      + role       = "ecs_task_role"
    }

  # aws_instance.my_instance[0] will be created
  + resource "aws_instance" "my_instance" {
      + ami                                  = "ami-0c55b159cbfafe1f0"
      + arn                                  = (known after apply)
      + associate_public_ip_address          = (known after apply)
      + availability_zone                    = (known after apply)
      + cpu_core_count                       = (known after apply)
      + cpu_threads_per_core                 = (known after apply)
      + disable_api_stop                     = (known after apply)
      + disable_api_termination              = (known after apply)
      + ebs_optimized                        = (known after apply)
      + get_password_data                    = false
      + host_id                              = (known after apply)
      + host_resource_group_arn              = (known after apply)
      + iam_instance_profile                 = (known after apply)
      + id                                   = (known after apply)
      + instance_initiated_shutdown_behavior = (known after apply)
      + instance_state                       = (known after apply)
      + instance_type                        = "t2.micro"
      + ipv6_address_count                   = (known after apply)
      + ipv6_addresses                       = (known after apply)
      + key_name                             = (known after apply)
      + monitoring                           = (known after apply)
      + outpost_arn                          = (known after apply)
      + password_data                        = (known after apply)
      + placement_group                      = (known after apply)
      + placement_partition_number           = (known after apply)
      + primary_network_interface_id         = (known after apply)
      + private_dns                          = (known after apply)
      + private_ip                           = (known after apply)
      + public_dns                           = (known after apply)
      + public_ip                            = (known after apply)
      + secondary_private_ips                = (known after apply)
      + security_groups                      = (known after apply)
      + source_dest_check                    = true
      + subnet_id                            = (known after apply)
      + tags                                 = {
          + "Name" = "my_instance-1"
        }
      + tags_all                             = {
          + "Name" = "my_instance-1"
        }
      + tenancy                              = (known after apply)
      + user_data                            = (known after apply)
      + user_data_base64                     = (known after apply)
      + user_data_replace_on_change          = false
      + vpc_security_group_ids               = (known after apply)
    }

  # aws_kinesis_stream.my_stream will be created
  + resource "aws_kinesis_stream" "my_stream" {
      + arn                       = (known after apply)
      + encryption_type           = "NONE"
      + enforce_consumer_deletion = false
      + id                        = (known after apply)
      + name                      = "my_stream"
      + retention_period          = 24
      + shard_count               = 1
      + tags_all                  = (known after apply)
    }

  # aws_lambda_function.my_lambda_function will be created
  + resource "aws_lambda_function" "my_lambda_function" {
      + architectures                  = (known after apply)
      + arn                            = (known after apply)
      + filename                       = "real-time-consumer.zip"
      + function_name                  = "my_lambda_function"
      + handler                        = "index.handler"
      + id                             = (known after apply)
      + invoke_arn                     = (known after apply)
      + last_modified                  = (known after apply)
      + memory_size                    = 128
      + package_type                   = "Zip"
      + publish                        = false
      + qualified_arn                  = (known after apply)
      + qualified_invoke_arn           = (known after apply)
      + reserved_concurrent_executions = -1
      + role                           = (known after apply)
      + runtime                        = "nodejs14.x"
      + signing_job_arn                = (known after apply)
      + signing_profile_version_arn    = (known after apply)
      + skip_destroy                   = false
      + source_code_hash               = (known after apply)
      + source_code_size               = (known after apply)
      + tags_all                       = (known after apply)
      + timeout                        = 3
      + version                        = (known after apply)
    }

  # aws_lambda_permission.my_permission will be created
  + resource "aws_lambda_permission" "my_permission" {
      + action              = "lambda:InvokeFunction"
      + function_name       = "my_lambda_function"
      + id                  = (known after apply)
      + principal           = "events.amazonaws.com"
      + source_arn          = (known after apply)
      + statement_id        = "AllowExecutionFromCloudWatch"
      + statement_id_prefix = (known after apply)
    }

  # aws_lb.my-lb will be created
  + resource "aws_lb" "my-lb" {
      + arn                                         = (known after apply)
      + arn_suffix                                  = (known after apply)
      + desync_mitigation_mode                      = "defensive"
      + dns_name                                    = (known after apply)
      + drop_invalid_header_fields                  = false
      + enable_deletion_protection                  = false
      + enable_http2                                = true
      + enable_tls_version_and_cipher_suite_headers = false
      + enable_waf_fail_open                        = false
      + enable_xff_client_port                      = false
      + id                                          = (known after apply)
      + idle_timeout                                = 60
      + internal                                    = false
      + ip_address_type                             = (known after apply)
      + load_balancer_type                          = "application"
      + name                                        = "my-lb"
      + preserve_host_header                        = false
      + security_groups                             = (known after apply)
      + subnets                                     = [
          + "subnet-049ac40c7fa73e691",
          + "subnet-058913b23d9c72eb1",
          + "subnet-092317f239795c6c0",
          + "subnet-0b05e8e772705b1eb",
        ]
      + tags                                        = {
          + "Name" = "my-lb"
        }
      + tags_all                                    = {
          + "Name" = "my-lb"
        }
      + vpc_id                                      = (known after apply)
      + xff_header_processing_mode                  = "append"
      + zone_id                                     = (known after apply)
    }

  # aws_lb_listener.http will be created
  + resource "aws_lb_listener" "http" {
      + arn               = (known after apply)
      + id                = (known after apply)
      + load_balancer_arn = (known after apply)
      + port              = 443
      + protocol          = "HTTP"
      + ssl_policy        = (known after apply)
      + tags_all          = (known after apply)

      + default_action {
          + order            = (known after apply)
          + target_group_arn = (known after apply)
          + type             = "forward"
        }
    }

  # aws_lb_target_group.mytg will be created
  + resource "aws_lb_target_group" "mytg" {
      + arn                                = (known after apply)
      + arn_suffix                         = (known after apply)
      + connection_termination             = false
      + deregistration_delay               = "300"
      + id                                 = (known after apply)
      + ip_address_type                    = (known after apply)
      + lambda_multi_value_headers_enabled = false
      + load_balancing_algorithm_type      = (known after apply)
      + load_balancing_cross_zone_enabled  = (known after apply)
      + name                               = "mytg"
      + port                               = 443
      + preserve_client_ip                 = (known after apply)
      + protocol                           = "HTTP"
      + protocol_version                   = (known after apply)
      + proxy_protocol_v2                  = false
      + slow_start                         = 0
      + tags_all                           = (known after apply)
      + target_type                        = "instance"
      + vpc_id                             = "vpc-0bd5ca5c81f3fb195"

      + health_check {
          + enabled             = true
          + healthy_threshold   = 3
          + interval            = 30
          + matcher             = (known after apply)
          + path                = "/"
          + port                = "traffic-port"
          + protocol            = "HTTP"
          + timeout             = (known after apply)
          + unhealthy_threshold = 3
        }
    }

  # aws_s3_bucket.my_bucket will be created
  + resource "aws_s3_bucket" "my_bucket" {
      + acceleration_status         = (known after apply)
      + acl                         = "private"
      + arn                         = (known after apply)
      + bucket                      = "my-bucket"
      + bucket_domain_name          = (known after apply)
      + bucket_prefix               = (known after apply)
      + bucket_regional_domain_name = (known after apply)
      + force_destroy               = false
      + hosted_zone_id              = (known after apply)
      + id                          = (known after apply)
      + object_lock_enabled         = (known after apply)
      + policy                      = (known after apply)
      + region                      = (known after apply)
      + request_payer               = (known after apply)
      + tags_all                    = (known after apply)
      + website_domain              = (known after apply)
      + website_endpoint            = (known after apply)

      + versioning {
          + enabled    = true
          + mfa_delete = false
        }
    }

  # aws_s3_bucket_lifecycle_configuration.bucket-config will be created
  + resource "aws_s3_bucket_lifecycle_configuration" "bucket-config" {
      + bucket = (known after apply)
      + id     = (known after apply)

      + rule {
          + id     = "expire-old-events"
          + status = "Enabled"

          + expiration {
              + days                         = 30
              + expired_object_delete_marker = (known after apply)
            }

          + filter {
              + and {}
            }
        }
    }

  # aws_s3_bucket_policy.lambda_bucket_policy will be created
  + resource "aws_s3_bucket_policy" "lambda_bucket_policy" {
      + bucket = (known after apply)
      + id     = (known after apply)
      + policy = (known after apply)
    }

  # aws_security_group.lbsg will be created
  + resource "aws_security_group" "lbsg" {
      + arn                    = (known after apply)
      + description            = "Managed by Terraform"
      + egress                 = (known after apply)
      + id                     = (known after apply)
      + ingress                = (known after apply)
      + name                   = "Dev Load Balancer"
      + name_prefix            = (known after apply)
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + tags_all               = (known after apply)
      + vpc_id                 = "vpc-0bd5ca5c81f3fb195"
    }

  # aws_sns_topic.my_topic will be created
  + resource "aws_sns_topic" "my_topic" {
      + arn                         = (known after apply)
      + content_based_deduplication = false
      + fifo_topic                  = false
      + id                          = (known after apply)
      + name                        = "my_topic"
      + name_prefix                 = (known after apply)
      + owner                       = (known after apply)
      + policy                      = (known after apply)
      + signature_version           = (known after apply)
      + tags_all                    = (known after apply)
      + tracing_config              = (known after apply)
    }

Plan: 30 to add, 0 to change, 0 to destroy.

Changes to Outputs:
  + dynamodb_table_name        = "my_table"
  + ecs_cluster_arn            = (known after apply)
  + ecs_task_definition_arn    = (known after apply)
  + elb_dns_name               = (known after apply)
  + kinesis_stream_name        = "my_stream"
  + lambda_function_arn        = (known after apply)
  + processed_data_bucket_name = (known after apply)
  + sns_topic_arn              = (known after apply)
╷
│ Warning: Deprecated Resource
│ 
│   with data.aws_subnet_ids.subnets,
│   on main.tf line 30, in data "aws_subnet_ids" "subnets":
│   30: data "aws_subnet_ids" "subnets" {
│ 
│ The aws_subnet_ids data source has been deprecated and will be removed in a future version. Use the aws_subnets data source instead:
│ https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnets
│ 
│ (and one more similar warning elsewhere)
╵
╷
│ Warning: Argument is deprecated
│ 
│   with aws_s3_bucket.my_bucket,
│   on main.tf line 349, in resource "aws_s3_bucket" "my_bucket":
│  349: resource "aws_s3_bucket" "my_bucket" {
│ 
│ Use the aws_s3_bucket_versioning resource instead
│ 
│ (and 3 more similar warnings elsewhere)
╵

──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────

Note: You didn't use the -out option to save this plan, so Terraform can't guarantee to take exactly these actions if you run "terraform apply" now.