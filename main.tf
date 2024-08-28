
data "aws_caller_identity" "current"{}

data "aws_region" "current"{}

data "local_file" "pet_tamer_py" {
  filename = "${path.module}/files/pet_tamer.py"
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = data.local_file.pet_tamer_py.filename
  output_path = "${path.module}/files/pet_tamer.zip"
}


output "lambda_arn" {
  value = module.lambda_with_logs.lambda_function_arn
}

#Deploys ssm parameters for each service group that created
module "ssm_paramater_store" {
  for_each = toset(var.servicegroups)
  source = "./modules/ssm-parameters"
  servicegroup = each.value
}


module "controller_role" {
  source = "./modules/controller-role"
  controller_account_id = data.aws_caller_identity.current.account_id
  region = data.aws_region.current.name
  
}
#You will need to add a module call for each target account you wish to add due to Terraforms lack of 
#provider templating. If single account. Just remove the providers block. 
module "target_role_account1" {
  source = "./modules/target-role"
  providers = {
    aws = aws.target_account1
  }
  controller_account_id = var.controller_account

}

# Deploy the Lambda function and associated CloudWatch log group
module "lambda_with_logs" {
  source                 = "./modules/lambda"
  file_path               = data.archive_file.lambda_zip.output_path
  function_name          = "pet_tamerLambda"
  role_arn               = module.controller_role.lambda_role_arn
  handler                = "pet_tamer.lambda_handler"
  runtime                = "python3.9"
  log_retention_in_days  = 3  # Adjust as needed
}

# Deploy API Gateway that invokes the Lambda function
module "api_gateway" {
  source      = "./modules/api-gateway"
  lambda_invoke_arn  = module.lambda_with_logs.lambda_invoke_arn
  lambda_name = module.lambda_with_logs.lambda_function_name
}