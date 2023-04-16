# AWS Architecture Diagram

```mermaid
graph TD;
    subgraph Data Ingestion
        I[Internet] --> LB[ALB];
        LB --> Z[API Gateway];
        Z --> K[Kinesis Stream];
        K --> D1[Data Store];
        K --> D2[Data Store];
        K --> D3[Data Store];
        K --> D4[Data Store];
    end

    subgraph Event Consumption
        D1 --> E1[Lambda Function];
        D2 --> E1;
        D3 --> E1;
        D4 --> E1;

        E1 --> D5[DynamoDB Table];

        D5 --> F1[Fargate Task];
        D5 --> L1[Lambda Function];

        F1 --> ECR;
        ECR --> EC2[EC2 Instance];
        L1 --> VPC;
    end

    subgraph Monitoring
        CloudWatchLogs1[D1 CloudWatch Logs] --> CloudWatchDashboards1[CloudWatch Dashboards];
        CloudWatchLogs1[D2 CloudWatch Logs] --> CloudWatchDashboards1;
        CloudWatchLogs1[D3 CloudWatch Logs] --> CloudWatchDashboards1;
        CloudWatchLogs1[D4 CloudWatch Logs] --> CloudWatchDashboards1;
        CloudWatchLogs2[F1 CloudWatch Logs] --> CloudWatchDashboards2[CloudWatch Dashboards];
        CloudWatchLogs3[L1 CloudWatch Logs] --> CloudWatchDashboards2;
        CloudWatchLogs4[API Gateway CloudWatch Logs] --> CloudWatchDashboards3[CloudWatch Dashboards];
    end

    subgraph Security
        ACM[ACM Certificates] --> LB;
        WAF[WAF] --> LB;
    end

    subgraph Availability
        subgraph Multi-AZ
            EC2 --> S1[Amazon S3];
            F1 --> S1;
            L1 --> S1;
        end

        subgraph Multi-Region
            D1 --> R1[Kinesis Data Stream in Region 2];
            D2 --> R1;
            D3 --> R1;
            D4 --> R1;
            R1 --> E1;
            R1 --> S2[Amazon S3 in Region 2];
            S1 --> S2;
        end

        LB --> EC2;
    end

    subgraph Retention
        D1 --> R2[S3 Bucket for Event Retention];
        D2 --> R2;
        D3 --> R2;
        D4 --> R2;
        R2 --> Lifecycle[R2 Object Lifecycle Policy];
    end

    subgraph Requirements
        style LB fill:#ffddcc;
        style Z fill:#ffffcc;
        style K fill:#ccffff;
        style D1,D2,D3,D4 fill:#ccffcc;
        style E1,L1 fill:#ccccff;
        style F1 fill:#ddccff;
        style S1,S2,R2 fill:#ffccdd;
    end



