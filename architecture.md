# AWS Architecture Diagram

```mermaid
graph TD
subgraph Public
  APIGateway((API Gateway))
  subgraph Availability
    CloudFront((CloudFront))
  end
end
subgraph Ingestion
  ALB((ALB))
  subgraph Autoscaling
    ECS(ECS)
    Fargate(Fargate)
  end
end
subgraph Data
  Kinesis((Kinesis)))
  subgraph Processing
    subgraph Real-Time
      Lambda((Lambda))
    end
    subgraph Batch
      ECS2(ECS)
      Fargate2(Fargate)
    end
  end
  subgraph Retention
    subgraph S3
      S3((S3))
    end
    subgraph DynamoDB
      DynamoDB((DynamoDB))
    end
  end
end

APIGateway -- TLS 1.2 --> ALB
ALB --> ECS
ECS --> Kinesis
Kinesis --> Lambda
Kinesis --> S3
S3 -- Lifecycle --> DynamoDB
ECS2 --> Kinesis
Kinesis --> Fargate
Fargate --> DynamoDB
CloudFront --> APIGateway
