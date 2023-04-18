# AWS Architecture Diagram

```mermaid
graph TD
    subgraph Internet
        client[Customer] --> API_Gateway[API Gateway]
    end
    subgraph AWS
        API_Gateway --> ELB[ELB]
        ELB --> Kinesis[Kinesis Stream]
        Kinesis --> S3[S3 Bucket]
        Kinesis --> SNS[SNS Topic]
        SNS --> Lambda[Lambda Function]
        SNS --> ECS_Fargate[ECS Fargate Task]
        Lambda --> DynamoDB[DynamoDB Table]
        Lambda --> S3
        ECS_Fargate --> DynamoDB
        ECS_Fargate --> S3
        S3 --> |Processed Data| Consumers[Consumers in eu-west-1]
    end
    subgraph Consumers
        Consumers --> DynamoDB
        Consumers --> |Processed Data| S3
    end
