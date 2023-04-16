# AWS Architecture Diagram

```mermaid
flowchart TD
  subgraph "Internet"
    PublicEndpoint
  end
  
  subgraph "AWS Global Infrastructure"
    subgraph "Elastic Load Balancer"
      PublicEndpoint --> ELB{ELB}
    end
    subgraph "Amazon Route 53"
      ELB -->|DNS resolution| Route53{Route 53}
    end
    subgraph "Amazon Certificate Manager"
      ELB -->|TLS termination| ACM{ACM}
    end
    subgraph "Amazon VPC"
      subgraph "Availability Zone A"
        ECSSubnetA1[EC2 Subnet A-1]
        ECSSubnetA2[EC2 Subnet A-2]
        NLB_A{NLB A}
      end
      subgraph "Availability Zone B"
        ECSSubnetB1[EC2 Subnet B-1]
        ECSSubnetB2[EC2 Subnet B-2]
        NLB_B{NLB B}
      end
      subgraph "Availability Zone C"
        ECSSubnetC1[EC2 Subnet C-1]
        ECSSubnetC2[EC2 Subnet C-2]
        NLB_C{NLB C}
      end
    end
    subgraph "Amazon ECS"
      subgraph "Task Definition"
        ECS_Task{ECS Task Definition}
      end
      subgraph "ECS Cluster"
        ECS_Cluster{ECS Cluster}
        ECS_Task -->|Execution| ECS_Cluster
      end
      subgraph "ECS Service"
        ECS_Service{ECS Service}
        ECS_Service -->|Auto Scaling| ECS_Cluster
      end
      subgraph "Amazon Fargate"
        ECS_Fargate{ECS Fargate}
        ECS_Fargate -->|Execution| ECS_Cluster
        ECS_Fargate -->|Auto Scaling| ECS_Service
      end
    end
    subgraph "Amazon S3"
      S3_Bucket{S3 Bucket}
    end
    subgraph "Amazon Kinesis Data Firehose"
      KDF{Kinesis Data Firehose}
      KDF --> S3_Bucket
    end
    subgraph "Amazon Kinesis Data Streams"
      KDS{Kinesis Data Streams}
      KDS -->|Sharding| ECS_Fargate
      KDS -->|Sharding| Lambda
    end
    subgraph "AWS Lambda"
      Lambda{Lambda}
      Lambda -->|Event Trigger| KDS
    end
    subgraph "AWS Systems Manager Parameter Store"
      ParamStore{Parameter Store}
    end
    subgraph "Amazon CloudWatch Logs"
      CloudWatch{CloudWatch Logs}
      CloudWatch -->|Log Collection| ECS_Fargate
      CloudWatch -->|Log Collection| Lambda
    end
    subgraph "Amazon CloudWatch Alarms"
      CloudWatchAlarms{CloudWatch Alarms}
      CloudWatchAlarms -->|Alerts| SNS
    end
    subgraph "Amazon Simple Notification Service"
      SNS{SNS}
    end
    
    subgraph "Internal Systems"
      subgraph "Amazon RDS"
        RDS{Amazon RDS}
      end
      subgraph "Amazon Redshift"
        Redshift{Amazon Redshift}
      end
      subgraph "Amazon Elasticsearch Service"
        ES{Amazon Elasticsearch Service}
      end
      subgraph "Amazon Sagemaker"
        Sagemaker{Amazon Sagemaker}
      end
      subgraph "Amazon EMR"
        EMR{Amazon EMR}
      end
      subgraph "Amazon Glue
