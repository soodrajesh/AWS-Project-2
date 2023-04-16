# AWS Architecture Diagram

```mermaid
flowchart LR

subgraph "Public Internet"
  PubEP("Public Endpoint") --> ALB
end

subgraph "AWS"
  subgraph "Load Balancer"
    ALB[ALB]
  end
  
  subgraph "Auto Scaling Group"
    ASG[ASG]
  end
  
  subgraph "Elasticache Cluster"
    ElastiCache
  end
  
  subgraph "Kinesis Data Stream"
    Kinesis
  end
  
  subgraph "S3 Bucket"
    S3
  end
  
  subgraph "Lambda Function"
    Lambda
  end
  
  subgraph "Batch Job"
    BatchJob
  end
  
  subgraph "ECS Fargate Task"
    ECS
  end
  
  subgraph "Internal Systems"
    InternalSystems
  end
  
  subgraph "CloudWatch"
    CloudWatch
  end
  
  ALB --> ASG
  ASG --> ElastiCache
  ASG --> Kinesis
  ASG --> S3
  Kinesis --> Lambda
  Lambda --> InternalSystems
  Lambda --> S3
  BatchJob --> ECS
  ECS --> InternalSystems
  InternalSystems --> CloudWatch
  ElastiCache --> CloudWatch
  Kinesis --> CloudWatch
  S3 --> CloudWatch
  
end
