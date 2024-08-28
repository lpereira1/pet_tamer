resource "aws_api_gateway_rest_api" "pet_tamer_api" {
  name        = "pet_tamerAPI"
  description = "API Gateway to manage EC2 instances across multiple accounts"
}

resource "aws_api_gateway_resource" "pet_tamer_resource" {
  rest_api_id = aws_api_gateway_rest_api.pet_tamer_api.id
  parent_id   = aws_api_gateway_rest_api.pet_tamer_api.root_resource_id
  path_part   =  var.lambda_name
}

resource "aws_api_gateway_method" "post_method" {
  rest_api_id   = aws_api_gateway_rest_api.pet_tamer_api.id
  resource_id   = aws_api_gateway_resource.pet_tamer_resource.id
  http_method   = "POST"
  authorization = "NONE"
  api_key_required = true
}

resource "aws_api_gateway_integration" "lambda_integration" {
  rest_api_id             = aws_api_gateway_rest_api.pet_tamer_api.id
  resource_id             = aws_api_gateway_resource.pet_tamer_resource.id
  http_method             = aws_api_gateway_method.post_method.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_invoke_arn
}

resource "aws_lambda_permission" "api_gateway_invoke_lambda" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = var.lambda_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.pet_tamer_api.execution_arn}/*/*"
}

resource "aws_api_gateway_deployment" "api_deployment" {
  depends_on = [aws_api_gateway_method.post_method]
  rest_api_id = aws_api_gateway_rest_api.pet_tamer_api.id
  stage_name  = "prod"
}

output "api_endpoint" {
  value = aws_api_gateway_deployment.api_deployment.invoke_url
}


resource "aws_api_gateway_api_key" "pet_tamer_api_key" {
  name        = "pet_tamerAPIKey"
  description = "API key for accessing the EC2 Management API"
  enabled     = true
}

resource "aws_api_gateway_usage_plan" "pet_tamer_usage_plan" {
  name        = "pet_tamerUsagePlan"
  description = "Usage plan for EC2 Management API"
  api_stages {
    api_id = aws_api_gateway_rest_api.pet_tamer_api.id
    stage  = aws_api_gateway_deployment.api_deployment.stage_name
  }
}

resource "aws_api_gateway_usage_plan_key" "pet_tamer_usage_plan_key" {
  key_id        = aws_api_gateway_api_key.pet_tamer_api_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.pet_tamer_usage_plan.id
}




output "api_key" {
  value = aws_api_gateway_api_key.pet_tamer_api_key.value
  description = "API key for accessing the EC2 Management API"
  sensitive   = true
}