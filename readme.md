# Pet Tamer Terraform Project

[![Terraform](https://img.shields.io/badge/Terraform-0.12+-623CE4?style=for-the-badge&logo=terraform)](https://www.terraform.io/)
[![Python](https://img.shields.io/badge/Python-3.8+-3776AB?style=for-the-badge&logo=python)](https://www.python.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg?style=for-the-badge&logo=MIT)](https://opensource.org/licenses/MIT)
## Overview

The **Pet Tamer** project is an infrastructure-as-code solution designed to manage EC2 instances across multiple AWS accounts based on specific tags and parameters. Unlike traditional auto-scaling groups, this project is tailored for "Pet" servers—machines that should never be terminated but can be turned off or on based on external triggers. This setup is ideal for scenarios where you need to control server power states using external metrics or alerts.

### Key Features

- **Minimum Server Count**: Ability to set a minimum number of servers that should always remain active in a service group, ensuring critical operations are always supported.
- **Flexible Server Management**: The API call can request to power on or off any number of servers within the group, allowing for precise scaling based on real-time needs.
- **Multi-Account Deployment**: Supports managing EC2 instances across multiple AWS accounts, with a central controller account assuming roles in target accounts.
- **API-Driven Control**: External systems (e.g., monitoring tools, APMs) can trigger server management actions via API Gateway, making the system highly responsive to changes in workload or performance metrics.


## Project Structure

Here's an overview of the project's structure:

| Directory/File                | Description                                                                 |
| ----------------------------- | --------------------------------------------------------------------------- |
| `provider.tf`                 | Configures the AWS provider for the Terraform project.                      |
| `main.tf`                     | Orchestrates the deployment of resources, including the invocation of modules. |
| `variables.tf`                | Contains variables used throughout the Terraform project.                   |
| `modules/api-gateway/`        | Manages the API Gateway to handle external requests.                        |
| `modules/controller-role/`    | Manages IAM roles for the controller account.                               |
| `modules/lambda/`             | Contains the Lambda function code and configuration.                        |
| `modules/ssm-parameters/`     | Manages SSM parameters used to control EC2 instances.                       |
| `modules/target-role/`        | Manages IAM roles in target accounts.                                        |
| `files/pet_tamer.py`          | Python script used within the project.                                       |

## Setup Instructions

### 1. Clone the Repository

Clone the project repository to your local machine:

```bash
git clone https://github.com/your-repo/pet_tamer.git
cd pet_tamer
```

### 2. Configure Variables

Update the `variables.tf` file with your specific AWS account IDs, regions, service groups, and minimum server counts:

```hcl
variable "aws_region" {
  description = "The AWS region to deploy resources in."
  default     = "us-west-2"
}

variable "controller_account_id" {
  description = "The AWS account ID for the controller."
  type        = string
}

variable "target_account_ids" {
  description = "List of target AWS account IDs."
  type        = list(string)
}

variable "service_group_min_count" {
  description = "Minimum number of servers that should always be running in each service group."
  type        = map(number)
  default     = {
    "web-servers" = 2,
    "app-servers" = 1
  }
}
```

### 3. Initialize Terraform

Initialize the Terraform project to download necessary providers and modules:

```bash
terraform init
```

### 4. Deploy the Infrastructure

Deploy the infrastructure using Terraform:

```bash
terraform apply
```

Review the proposed changes and confirm to apply.

### 5. Test Locally (Optional)

If you want to test the setup locally, you can simulate API requests using `curl` or Postman.

## Usage Examples

### Controlling EC2 Instances

Use the API Gateway endpoint to manage EC2 instances by making HTTP POST requests. Below are some examples:

- **Start a Specific Number of Instances in a Service Group:**

  ```bash
  curl -X POST https://your-api-endpoint.amazonaws.com/dev/start \
  -d '{"service_group": "web-servers", "action": "start", "count": 3}'
  ```

  > This request will attempt to start 3 instances in the "web-servers" group, adhering to the minimum count.

- **Stop a Specific Number of Instances in a Service Group:**

  ```bash
  curl -X POST https://your-api-endpoint.amazonaws.com/dev/stop \
  -d '{"service_group": "app-servers", "action": "stop", "count": 1}'
  ```

  > This request will attempt to stop 1 instance in the "app-servers" group, ensuring that the minimum count is maintained.

- **Ensure Minimum Servers Are Running:**

  The system automatically ensures that the minimum number of servers defined in `service_group_min_count` is always running, even after stop requests.

## How It Works

- **IAM Roles**: Sets up IAM roles in both the controller and target accounts, allowing the Lambda function to assume roles in target accounts and manage EC2 instances.
- **SSM Parameters**: Uses SSM parameters to store configuration values like minimum server counts for service groups.
- **Lambda Function**: Triggered by API Gateway, the Lambda function manages EC2 instances by assuming roles in target accounts and executing actions.
- **API Gateway**: Provides an external endpoint to trigger the Lambda function, enabling automated and remote management of EC2 instances.

## Security Considerations

- Ensure IAM roles and policies are tightly scoped to avoid unnecessary permissions.
- Use secure methods for storing and retrieving sensitive data, such as environment variables and secrets.
- Regularly review and rotate IAM credentials and API keys.

## Troubleshooting

- **Lambda Invocation Issues**: Ensure the API Gateway has the necessary permissions to invoke the Lambda function.
- **IAM Role Assumption Errors**: Verify that the IAM roles in target accounts trust the controller account and allow `sts:AssumeRole`.
- **Parameter Store Access**: Ensure that the IAM roles have the necessary permissions to access SSM parameters.

## Contributions

Contributions to this project are welcome! Please submit issues and pull requests to improve the project.

## License

This project is licensed under the MIT License.
