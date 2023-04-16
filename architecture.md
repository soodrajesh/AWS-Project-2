# AWS Architecture Diagram

```mermaid
graph TD;
  subgraph Ingestion Layer
    PubSub[Public Endpoint]
    ALB[Application Load Balancer]
    ECS[ECS Cluster]
    Fargate[ECS Fargate Task]
    Kinesis[Kinesis Data Stream]
    subgraph Availability Zone 1
      Kinesis1[Kinesis Shard 1]
      Kinesis2[Kinesis Shard 2]
      Kinesis3[Kinesis Shard 3]
    end
    subgraph Availability Zone 2
      Kinesis4[Kinesis Shard 4]
      Kinesis5[Kinesis Shard 5]
      Kinesis6[Kinesis Shard 6]
    end
  end
  subgraph Consumption Layer
    Lambda[Lambda Function]
    DynamoDB[DynamoDB Table]
  end
  subgraph Internal Systems
    BatchJob[Batch Job]
  end
  subgraph Users
    Users[Users Worldwide]
  end
  Users--HTTPs-->PubSub
  PubSub--HTTPs-->ALB
  ALB--HTTP-->ECS
  ECS--HTTP-->Fargate
  Fargate--KPL-->Kinesis
  Kinesis--Lambda-->DynamoDB
  Kinesis--BatchJob-->S3
```
