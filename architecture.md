# AWS Architecture Diagram

```mermaid
flowchart TB
    subgraph "Public Endpoint"
        subgraph "ALB"
            ALB
        end
        subgraph "Target Group"
            Target_Group
        end
        subgraph "EC2 instances"
            EC2_instances
        end
        subgraph "Auto Scaling Group"
            Auto_Scaling_Group
        end
        ALB-->"Redirect to HTTPS"-->ALB
        ALB-->Target_Group
        Target_Group-->EC2_instances
        EC2_instances-->Auto_Scaling_Group
    end
    subgraph "Kinesis Firehose"
        Kinesis_Firehose
    end
    subgraph "S3"
        S3
    end
    subgraph "ECS Fargate Task"
        ECS_Fargate_Task
    end
    subgraph "Lambda Function"
        Lambda_Function
    end
    subgraph "Internal Systems"
        Internal_Systems
    end
    subgraph "CloudWatch Events"
        CloudWatch_Events
    end
    
    subgraph "Worldwide Access"
        ALB-->|"TLS 1.2"|Kinesis_Firehose
    end
    Kinesis_Firehose-->S3
    S3-->ECS_Fargate_Task
    S3-->Lambda_Function
    S3-->Internal_Systems
    S3-->CloudWatch_Events
    ECS_Fargate_Task-->|"Java Runtime"|Internal_Systems
    Lambda_Function-->|"NodeJS Runtime"|Internal_Systems
    S3-->|"30 Days retention"|Internal_Systems
