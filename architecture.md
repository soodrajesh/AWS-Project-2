# AWS Architecture Diagram

```mermaid
graph TD
  subgraph "Public Endpoint"
    Endpoint["API Gateway + HTTPS/TLS 1.2"]
  end
  subgraph "Data Ingestion"
    Endpoint --> ALB["Application Load Balancer"]
    ALB --> ECS[ECS Cluster]
    ECS --> Fargate["Fargate Task"]
    subgraph "Availability Zones"
      Fargate --> RDS[RDS Multi-AZ]
    end
  end
  subgraph "Data Processing"
    Fargate --> SQS["Amazon SQS"]
    SQS --> Lambda["Lambda Function"]
  end
  subgraph "Data Storage"
    RDS --> S3["S3 Bucket"]
  end
  subgraph "Consumers"
    Lambda --> Kinesis["Amazon Kinesis"]
    subgraph "Availability Zones"
      Kinesis --> EC2["EC2 Instance"]
    end
  end
  subgraph "Logging & Monitoring"
    CloudTrail["AWS CloudTrail"]
    CloudWatchLogs["CloudWatch Logs"]
    CloudWatchMetrics["CloudWatch Metrics"]
  end
