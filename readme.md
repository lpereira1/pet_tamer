# Pet Tamer Terraform Project

[![Terraform](https://img.shields.io/badge/Terraform-0.12+-623CE4?style=for-the-badge&logo=terraform)](https://www.terraform.io/)
[![Python](https://img.shields.io/badge/Python-3.8+-3776AB?style=for-the-badge&logo=python)](https://www.python.org/)

## Overview

The **Pet Tamer** project is an infrastructure-as-code solution that manages EC2 instances across multiple AWS accounts based on specific tags and parameters. It utilizes Terraform to deploy IAM roles, API Gateway, Lambda functions, and SSM parameters that work together to automate the management of EC2 instances.

## Project Structure

```
pet_tamer/
│
├── provider.tf
├── main.tf
├── api_gateway.tf
├── variables.tf
├── modules/
│   ├── target-role/
│   │   ├── target_roles.tf
│   │   └── variables.tf
│   ├── ssm-parameters/
│   │   ├── ssm_parameters.tf
│   │   └── variables.tf
│   └── controller-role/
│       ├── controller-roles.tf
│       └── variables.tf
└── files/
    └── pets.py
```

### **File and Directory Descriptions**

- **`provider.tf`**: Configures the AWS provider for the Terraform project, including the AWS region.
- **`main.tf`**: The primary Terraform configuration file that orchestrates the deployment of resources, including the invocation of modules.
- **`api_gateway.tf`**: Defines the API Gateway that triggers the Lambda function, allowing external requests to manage EC2 instances.
- **`variables.tf`**: Contains variables used throughout the Terraform project, such as AWS region, controller account ID, and service groups.
- **`modules/`**:
  - **`target-role/`**: Manages IAM roles in target accounts that the controller account's Lambda function can assume to manage EC2 instances.
    - **`target_roles.tf`**: Defines the IAM roles and policies for target accounts.
    - **`variables.tf`**: Variables specific to the target roles module.
  - **`ssm-parameters/`**: Creates and manages SSM parameters used by the Lambda function to control EC2 instance behavior.
    - **`ssm_parameters.tf`**: Defines the SSM parameters.
    - **`variables.tf`**: Variables specific to the SSM parameters module.
  - **`controller-role/`**: Manages the IAM role in the controller account that the Lambda function assumes to manage target accounts.
    - **`controller-roles.tf`**: Defines the IAM roles and policies for the controller account.
    - **`variables.tf`**: Variables specific to the controller roles module.
- **`files/`**:
  - **`pets.py`**: The Lambda function script that manages EC2 instances based on incoming requests from the API Gateway.

## Prerequisites

Before you begin, ensure you have the following installed:

- Terraform (version 0.12 or later)
- AWS CLI configured with the necessary permissions to deploy resources

## Setup Instructions

1. **Clone the Repository**

   Clone this repository to your local machine:

   ```bash
   git clone https://github.com/yourusername/pet-tamer.git
   cd pet-tamer
   ```

2. **Initialize Terraform**

   Initialize the Terraform project to download required providers:

   ```bash
   terraform init
   ```

3. **Configure Variables**

   Modify the `variables.tf` file to set your AWS region, controller account ID, and service groups:

   ```hcl
   variable "region" {
     description = "The AWS region where the infrastructure will be deployed."
     type        = string
   }

   variable "controller_account" {
     description = "The AWS account ID of the controller account."
     type        = string
   }

   variable "servicegroups" {
     description = "List of service groups being managed."
     type        = list(string)
   }
   ```

4. **Deploy the Infrastructure**

   Run the following command to deploy the infrastructure:

   ```bash
   terraform apply
   ```

   Review the changes and confirm to apply.

5. **Invoke the Lambda Function**

   Use the API Gateway endpoint to manage EC2 instances by making HTTP requests. Ensure the requests include the necessary parameters and tags.

## How It Works

- **IAM Roles**: The project sets up IAM roles in both the controller and target accounts. The controller role allows the Lambda function to assume roles in target accounts and manage EC2 instances.
- **SSM Parameters**: SSM parameters are used to store configuration values, such as minimum server counts for service groups.
- **Lambda Function**: The Lambda function, triggered by API Gateway, manages EC2 instances by assuming roles in target accounts and executing actions like starting, stopping, or describing instances.
- **API Gateway**: The API Gateway provides an external endpoint to trigger the Lambda function, enabling automated and remote management of EC2 instances.

## Security Considerations

- Ensure IAM roles and policies are tightly scoped to avoid unnecessary permissions.
- Use secure methods for storing and retrieving sensitive data, such as environment variables and secrets.
- Regularly review and rotate IAM credentials and API keys.

## Troubleshooting

- **Lambda Invocation Issues**: Ensure the API Gateway has the necessary permissions to invoke the Lambda function.
- **IAM Role Assumption Errors**: Verify that the IAM roles in target accounts trust the controller account and allow `sts:AssumeRole`.
- **Parameter Store Access**: Ensure that the IAM roles have the necessary permissions to access SSM parameters.

## Contributions

Contributions to this project are welcome. Please submit issues and pull requests to improve the project.

## License

This project is licensed under the MIT License.