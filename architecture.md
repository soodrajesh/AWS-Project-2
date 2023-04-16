# AWS Architecture Diagram

```mermaid
flowchart TD
  subgraph "Public Internet"
    end1[Public Endpoint]
  end

  subgraph "Amazon VPC"
    subgraph "Public Subnet"
      LB[ALB]
      TG[NODEJS Lambda]
      end2((Endpoint))
    end

    subgraph "Private Subnet"
      subgraph "ECS Cluster"
        ECS1[ECS Fargate Task]
        ECS2[ECS Fargate Task]
      end
    end

    DB[RDS]

    subgraph "AWS PrivateLink"
      PL(PrivateLink Interface)
      end3((Endpoint))
    end

    subgraph "AWS Global Accelerator"
      GA[Global Accelerator]
    end

    subgraph "Amazon S3"
      S3[S3 Bucket]
    end

    end1-->LB
    LB-->TG
    end2-->LB
    TG-->DB
    ECS1-->DB
    ECS2-->DB
    DB-->PL
    PL-->GA
    GA-->S3
    S3-->end3
