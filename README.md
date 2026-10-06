## Project Context

This repository contains a cleaned public version of an Infrastructure-as-Code project developed for learning and demonstration purposes. The original project was developed and iterated on privately while studying AWS and Terraform. This public version reflects the final architecture and configuration used to deploy the infrastructure.
Sensitive identifiers such as AWS account IDs have been redacted.
# \# Terraform AWS Secure Foundations

# 

\# Terraform AWS Secure Foundations



Infrastructure-as-Code (IaC) labs using Terraform on AWS with security best practices.



\## Core Principles



\* No root account usage for daily operations

\* Least-privilege IAM access model

\* Role assumption using AWS STS

\* Remote Terraform state stored in S3

\* State locking using DynamoDB

\* Version-controlled infrastructure using GitHub



---



\# Project Goal



This repository demonstrates how to build a \*\*secure AWS infrastructure foundation using Terraform\*\*, similar to how real cloud engineering teams deploy and manage infrastructure.



Objectives:



1\. Deploy AWS infrastructure using Terraform rather than manual console configuration

2\. Store Terraform state remotely in S3

3\. Prevent state corruption using DynamoDB state locking

4\. Implement secure IAM practices (User → Assume Role)

5\. Track all infrastructure changes using GitHub



---



\# Architecture Overview



Infrastructure is deployed using a layered IAM access model.



```

Local Machine

&nbsp;     │

AWS CLI Credentials

&nbsp;     │

&nbsp;     ▼

IAM User: terraform-user

&nbsp;     │

AssumeRole (AWS STS)

&nbsp;     │

&nbsp;     ▼

IAM Role: TerraformAdminRole

&nbsp;     │

&nbsp;     ▼

Terraform deploys infrastructure

&nbsp;     │

&nbsp;     ▼

AWS Resources (S3, DynamoDB, EC2)

```



This design ensures that long-lived credentials are \*\*never given administrative privileges directly\*\*.



---



\# IAM Model



\## IAM User



\*\*terraform-user\*\*



Purpose:



\* Authenticates with AWS CLI

\* Stores access keys locally

\* Has minimal permissions



The user only exists to \*\*assume a role\*\*.



---



\## IAM Role



\*\*TerraformAdminRole\*\*



Purpose:



\* Grants temporary elevated permissions

\* Used by Terraform to create and manage AWS infrastructure



---



\## Role Assumption (STS)



Terraform workflow:



```

terraform-user

&nbsp;     │

&nbsp;     ▼

AssumeRole

&nbsp;     │

&nbsp;     ▼

TerraformAdminRole

&nbsp;     │

&nbsp;     ▼

Create AWS infrastructure

```



Real-world analogy:



| Concept    | Real-World Equivalent             |

| ---------- | --------------------------------- |

| IAM User   | Employee badge                    |

| IAM Role   | Master keys                       |

| AssumeRole | Temporarily checking out the keys |



---



\# Repository Structure



```

terraform-aws-secure-foundations

│

├── 01-s3-bucket

│   └── main.tf

│

├── 02-remote-backend

│   └── main.tf

│

├── 03-ec2-instance

│   └── main.tf

│

├── README.md

└── .gitignore

```



Each directory represents a \*\*separate Terraform project\*\* that builds part of the infrastructure foundation.



---



\# Completed Infrastructure



\## Project 01 — Secure S3 Bucket



Purpose:

Create a secure S3 bucket using Terraform.



Resources created:



\* S3 bucket

\* Public access block configuration



Security features:



\* Public access disabled

\* Bucket controlled entirely through Terraform



This project also demonstrates \*\*Terraform drift detection\*\*.



---



\## Project 02 — Remote Terraform Backend



Purpose:

Store Terraform state remotely for reliability and team collaboration.



Resources created:



\### Terraform State Bucket



```

dwight-terraform-state-2026-unique

```



Features:



\* Versioning enabled

\* Server-side encryption enabled



\### Terraform Lock Table



```

terraform-locks

```



Service used:



\* DynamoDB



Purpose:



\* Prevent multiple Terraform executions from modifying state simultaneously.



---



\## Project 03 — EC2 Instance Deployment



Purpose:

Deploy compute infrastructure using Terraform.



Resources created:



\* EC2 instance

\* Security group



Instance configuration:



| Setting        | Value        |

| -------------- | ------------ |

| Instance Type  | t3.micro     |

| Region         | us-west-2    |

| Security Group | ec2-basic-sg |



The instance was successfully deployed and verified in the AWS console.


\## Project 04 — VPC Network (no NAT to avoid cost)

Purpose:

Build a custom VPC with a public and private subnet in **us-west-2**.

Resources created:

- VPC (CIDR `10.10.0.0/16`) — `tf-vpc-04`

- Internet Gateway — `tf-igw-04`

- Public Subnet (CIDR `10.10.1.0/24`, auto public IPs) — `tf-public-a-04`

- Private Subnet (CIDR `10.10.11.0/24`) — `tf-private-a-04`

- Public Route Table with `0.0.0.0/0 -> IGW` — `tf-rt-public-04`

- Private Route Table (no default internet route) — `tf-rt-private-04`


Outputs:

- vpc_id

- public_subnet_id

- private_subnet_id

---

## Project 05a — EC2 Inside Custom VPC

Purpose:
Deploy an EC2 instance inside the custom VPC created in Project 04.

Resources created:
- EC2 instance
- Security group inside the custom VPC

Configuration:
- Instance type: `t3.micro`
- Region: `us-west-2`
- VPC: `tf-vpc-04`
- Subnet: public subnet from Project 04
- Security group: `ec2-basic-sg`

How it works:
- This project reads outputs from `04-vpc-network` using `terraform_remote_state`
- The EC2 instance is launched in the public subnet of the custom VPC
- The security group is also created inside the custom VPC

Outcome:
- EC2 is no longer deployed in the default AWS VPC
- Infrastructure is now connected as a real AWS architecture:
  - VPC
  - Public subnet
  - Internet gateway
  - EC2 instance

## Project 05b — EC2 Web Server inside Custom VPC

Purpose:

Deploy a web server inside the Terraform-built VPC and verify network connectivity.

Resources created:

- EC2 instance (`t3.micro`)
- Security group allowing SSH and HTTP
- Apache web server installed automatically via `user_data`

Networking:

- VPC: `tf-vpc-04`
- Public subnet: `10.10.1.0/24`
- Internet access through Internet Gateway

Verification:

The EC2 instance serves a webpage:

Hello from Whitey1700

Accessed through the instance public IP.

This confirms:

- VPC routing works
- Internet Gateway works
- Security group rules allow HTTP
- EC2 instance bootstrap script executed successfully

\# Terraform Workflow



Typical Terraform deployment process:



```

terraform init

terraform plan

terraform apply

```



Command explanations:



| Command           | Purpose                                      |

| ----------------- | -------------------------------------------- |

| terraform init    | Initializes Terraform project and providers  |

| terraform plan    | Shows infrastructure changes before applying |

| terraform apply   | Creates or modifies infrastructure           |

| terraform destroy | Removes infrastructure managed by Terraform  |



---



\# Remote Terraform State



Terraform state is stored in S3.



State bucket:



```

dwight-terraform-state-2026-unique

```



State locking table:



```

terraform-locks

```



Example backend configuration:



```

terraform {

&nbsp; backend "s3" {

&nbsp;   bucket         = "dwight-terraform-state-2026-unique"

&nbsp;   key            = "01-s3-bucket/terraform.tfstate"

&nbsp;   region         = "us-west-2"

&nbsp;   dynamodb\_table = "terraform-locks"

&nbsp;   encrypt        = true

&nbsp; }

}

```



Benefits:



\* Centralized state

\* Version history

\* State locking protection

\* Collaboration ready



---



\# Security Practices Implemented



\* No root account usage

\* IAM role assumption architecture

\* Terraform state encryption

\* Public access blocked for S3 buckets

\* Version-controlled infrastructure

\* Infrastructure deployed using IaC



---



\# Region Configuration



AWS resources are region-specific.



This project uses:



```

us-west-2 (Oregon)

```



If resources appear missing in the AWS console, verify the selected region.



---



\# Planned Infrastructure Expansion



Future Terraform projects will expand the environment.



\## Networking Infrastructure



Planned components:



\* Custom VPC

\* Public subnet

\* Private subnet

\* Route tables

\* Internet gateway



---



\## EC2 Improvements



Planned security enhancements:



\* Instance tagging

\* Encrypted EBS volumes

\* IAM roles for EC2

\* Replace SSH access with AWS Systems Manager



---



\## Additional Infrastructure



Future components may include:



\* Application Load Balancer

\* Auto Scaling Group

\* RDS database

\* CloudWatch monitoring

\* AWS Budgets cost monitoring



---



\# Important Security Notes



Do NOT commit the following files to GitHub:



```

.terraform/

\*.tfstate

terraform.tfstate.backup

AWS credentials

```



These files are excluded using `.gitignore`.



---



\# Useful Resources



Terraform Documentation

https://developer.hashicorp.com/terraform



AWS IAM Documentation

https://docs.aws.amazon.com/IAM/latest/UserGuide/introduction.html



AWS Global Infrastructure

https://aws.amazon.com/about-aws/global-infrastructure/regions\_az/



