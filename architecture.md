# AWS Architecture Diagram

```mermaid
flowchart LR
  subgraph "AWS Account"
    subgraph "Amazon API Gateway"
      apigateway["API Gateway"]
    end
    subgraph "Amazon EC2"
      nat["NAT Gateway"]
    end
    subgraph "Amazon VPC"
      internet["Internet Gateway"]
      subgraph "Public Subnet 1"
        apigateway-->internet
        nlb1["Network Load Balancer 1"]
        eip1["Elastic IP 1"]
        nlb1-->nat
        nlb1-->eip1
        sg["Security Group"]
        instance["Amazon EC2 instance"]
        sg-->instance
      end
      subgraph "Public Subnet 2"
        nlb2["Network Load Balancer 2"]
        eip2["Elastic IP 2"]
        nlb2-->nat
        nlb2-->eip2
        sg-->instance
      end
      subgraph "Private Subnet"
        rds["Amazon RDS"]
        instance-->rds
        nlb1r["NLB Listener Rule"]
        nlb1r-->rds
        nlb2r["NLB Listener Rule"]
        nlb2r-->rds
        lambda["AWS Lambda"]
        lambda-->rds
        fargate["AWS Fargate"]
        fargate-->rds
      end
    end
    subgraph "Amazon S3"
      s3["Amazon S3"]
      rds-->s3
      lambda-->s3
      fargate-->s3
    end
    subgraph "Terraform for AWS"
      cf["Terraform"]
    end
    cf-->apigateway
    cf-->nat
    cf-->internet
    cf-->nlb1
    cf-->nlb2
    cf-->sg
    cf-->instance
    cf-->rds
    cf-->nlb1r
    cf-->nlb2r
    cf-->lambda
    cf-->fargate
    cf-->s3
  end
