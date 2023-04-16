# AWS Architecture Diagram

```mermaid
flowchart LR

subgraph Ingestion Layer
  inputEndpoint((Input Endpoint))
  httpEncrypted[HTTP Encrypted via TLS 1.2]
  subgraph Load Balancer
    lb(Load Balancer)
  end
  subgraph Auto Scaling Group
    asg(Auto Scaling Group)
  end
  db1[Database 1]
  db2[Database 2]
end

subgraph Consumption Layer
  subgraph Batch Processing
    batchJob((Long-Running Batch Job))
    ecs(ECS Fargate)
    batchDB[Database]
  end

  subgraph Near-Real-Time Processing
    nrtJob((Near-Real-Time Consumer))
    lambda(Lambda)
    nrtDB[Database]
  end
end

subgraph Data Storage
  s3[S3 Bucket]
end

subgraph Monitoring
  cloudwatch(CloudWatch)
  alerts[Alerts]
end

subgraph Global Content Delivery
  cdn[CDN]
end

inputEndpoint-->httpEncrypted-->lb-->asg
asg-->db1
asg-->db2
db1-->s3
db2-->s3

batchJob-->ecs-->batchDB
nrtJob-->lambda-->nrtDB
s3-->batchDB
s3-->nrtDB

cdn-->inputEndpoint

cloudwatch-->inputEndpoint
cloudwatch-->asg
cloudwatch-->batchJob
cloudwatch-->nrtJob

alerts-->cloudwatch

