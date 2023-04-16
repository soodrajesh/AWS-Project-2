# AWS Architecture Diagram

```mermaid
graph LR
subgraph "Ingestion Layer"
  LB[Load Balancer]
  subgraph "Auto Scaling Group"
    ASG[Auto Scaling Group]
    EC2-1[EC2 Instance 1]
    EC2-2[EC2 Instance 2]
  end
  LB --> ASG
end

subgraph "Data Processing Layer"
  KIN[Kinesis Data Stream]
  subgraph "Consumer Group 1"
    FARG[ECS Fargate Task]
    JAV[Java Batch Job]
  end
  subgraph "Consumer Group 2"
    LAMB[Lambda Function]
    NJS[NodeJS Function]
  end
  KIN --> FARG
  FARG --> JAV
  KIN --> LAMB
  LAMB --> NJS
end

subgraph "Data Storage Layer"
  S3[S3 Bucket]
  DDB[ DynamoDB Table]
  KIN --- S3
  KIN --- DDB
end

subgraph "Global Traffic"
  DNS[Route 53 DNS]
  CDN[Amazon CloudFront]
  LB --- CDN
  CDN --- DNS
end

subgraph "Security"
  CERT[SSL Certificate]
  CERT --- LB
end
