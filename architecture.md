# AWS Architecture Diagram

```mermaid
graph TD
    subgraph Internet
        client[Client] --> API_Gateway[API Gateway]
    end
    subgraph AWS
        API_Gateway --> ELB[ELB]
        ELB --> EC2_EC[ECS]
        EC2_EC --> Kinesis[Kinesis Stream]
        Kinesis --> S3[S3 Bucket]
        Kinesis --> SNS[SNS Topic]
        SNS --> Lambda[Lambda Function]
        SNS --> ECS_Fargate[ECS Fargate Task]
        Lambda --> DynamoDB[DynamoDB Table]
        Lambda --> S3
        ECS_Fargate --> DynamoDB
        ECS_Fargate --> S3
        DynamoDB --> |Metadata| DynamoDB
        S3 --> |Processed Data| Consumers[Consumers in eu-west-1]
    end
    subgraph Consumers
        Consumers --> |Metadata| DynamoDB
        Consumers --> |Processed Data| S3
    end

