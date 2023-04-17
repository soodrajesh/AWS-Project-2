# AWS-Project-2
AWS-Project-2 using Terraform


As per the requirements, we can design the AWS architecture as follows:


**1. API Gateway:** We can create an API Gateway endpoint that can be accessed publicly without any authentication or authorization. This endpoint will receive the events and forward them to the backend for further processing.

**2. Elastic Load Balancer (ELB): ** We can use an ELB to distribute the traffic to multiple Amazon Elastic Compute Cloud (EC2) instances or containers in different regions. The ELB will also terminate the SSL/TLS connection, enabling the use of HTTPS to encrypt the traffic.

**3. Kinesis: **We can use Amazon Kinesis as the data ingestion layer. The events received by the API Gateway will be forwarded to an Amazon Kinesis stream. We can configure the stream to handle up to 500 events per second at peak times.

**4.  S3:** We can configure an S3 bucket as the destination for the Amazon Kinesis stream. The S3 bucket will be used as a backup for the events in case of any internal errors, ensuring that we don't lose any events.

**5. AWS Lambda**: We can create a Lambda function in the eu-west-1 region that will be triggered by new events arriving in the Kinesis stream. This Lambda function will be responsible for processing each new event as soon as possible.

**6. ECS Fargate:** We can create an ECS Fargate task that will run a long-running batch job. This task can be scheduled to run once per day at 3 am using AWS CloudWatch Events. The task will process all the events of the last 24 hours, and the processed data will be stored in Amazon S3.

**7. SNS:** We can configure an Amazon SNS topic to notify the subscribers (in this case, the ECS Fargate task and the Lambda function) when new events arrive in the Kinesis stream.

**8. DynamoDB:** We can create a DynamoDB table to store the metadata for the events. This table will be used to track the status of each event and ensure that we meet the SLAs.

**9. Multi-Region: **To make the system highly available and resilient, we can deploy the infrastructure in multiple regions. This ensures that the system can still ingest events even when one AWS region goes down.

The request flow for this architecture will be as follows:

1. A client sends an HTTPS request to the public endpoint of the API Gateway.

2. The API Gateway receives the request and forwards it to the ELB.

3. The ELB terminates the SSL/TLS connection and forwards the request to an EC2 instance or container in a specific region.

4. The EC2 instance or container forwards the request to the Kinesis stream.

5. The Kinesis stream receives the event and forwards it to the S3 bucket and the SNS topic.

6. The Lambda function and the ECS Fargate task receive a notification from the SNS topic.

7. The Lambda function processes the event and stores the processed data in the DynamoDB table and the S3 bucket.

8. The ECS Fargate task runs once per day at 3 am and processes all the events of the last 24 hours. The processed data is stored in the DynamoDB table and the S3 bucket.

9. The metadata for each event is stored in the DynamoDB table to track the status of each event and ensure that we meet the SLAs.

10. The subscribers (Lambda function and ECS Fargate task) continue to receive notifications from the SNS topic as new events arrive in the Kinesis stream.

11. The consumers in the eu-west-1 region can access the processed data from the S3 bucket. The metadata for each event is stored in the DynamoDB table and can be used to trackthe status of each event and ensure that the SLAs are met.

12. The events are retained in the S3 bucket for 30 days, providing the ability to re-read the events in case of bugs during processing.

This architecture provides a scalable, highly available, and resilient solution as per requirements. It also provides cost-effectiveness by using AWS managed services such as Kinesis, Lambda, and DynamoDB. Additionally, it provides ease of deployment, maintenance, and scaling since the infrastructure is managed as code by using Terraform.
