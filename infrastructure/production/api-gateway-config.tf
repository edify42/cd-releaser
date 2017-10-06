resource "aws_api_gateway_rest_api" "cd_releaser" {
  name = "cd_releaser"
  description = "API Gateway to access Lambda to keep CICD pipeline state"
}

resource "aws_api_gateway_resource" "api" {
  rest_api_id = "${aws_api_gateway_rest_api.cd_releaser.id}"
  parent_id = "${aws_api_gateway_rest_api.cd_releaser.root_resource_id}"
  path_part = "api"
}

resource "aws_api_gateway_method" "api_post" {
  rest_api_id = "${aws_api_gateway_rest_api.cd_releaser.id}"
  resource_id = "${aws_api_gateway_resource.api.id}"
  http_method = "POST"
  authorization = "NONE"
  api_key_required = true
}

# resource "aws_api_gateway_integration" "cd_releaser" {
#   rest_api_id = "${aws_api_gateway_rest_api.cd_releaser.id}"
#   resource_id = "${aws_api_gateway_resource.api.id}"
#   http_method = "${aws_api_gateway_method.api_post.http_method}"
#   type        = "MOCK"
# }

resource "aws_api_gateway_api_key" "cd_releaser" {
  name = "cd_releaser_api_key"
  value = "e775f398cadc4367093844ccbadae281b8fceb0a"
  stage_key {
    rest_api_id = "${aws_api_gateway_rest_api.cd_releaser.id}"
    stage_name  = "${aws_api_gateway_deployment.cd_releaser_deployment.stage_name}"
  }
}

resource "aws_api_gateway_deployment" "cd_releaser_deployment" {
  rest_api_id = "${aws_api_gateway_rest_api.cd_releaser.id}"
  stage_name  = "production"
}

resource "aws_api_gateway_usage_plan" "cd_releaser" {
  name         = "cd_releaser_usage_plan"
  description  = "hmmm"
  product_code = "MYCODE"

  api_stages {
    api_id = "${aws_api_gateway_rest_api.cd_releaser.id}"
    stage  = "${aws_api_gateway_deployment.cd_releaser_deployment.stage_name}"
  }

  quota_settings {
    limit  = 20
    offset = 2
    period = "WEEK"
  }

  throttle_settings {
    burst_limit = 5
    rate_limit  = 5
  }
}

resource "aws_api_gateway_usage_plan_key" "cd_releaser" {
  key_id        = "${aws_api_gateway_api_key.cd_releaser.id}"
  key_type      = "API_KEY"
  usage_plan_id = "${aws_api_gateway_usage_plan.cd_releaser.id}"
}


### Lambda integration
resource "aws_api_gateway_integration" "integration" {
  rest_api_id             = "${aws_api_gateway_rest_api.cd_releaser.id}"
  resource_id             = "${aws_api_gateway_rest_api.cd_releaser.root_resource_id}"
  http_method             = "${aws_api_gateway_method.api_post.http_method}"
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:ap-southeast-2:lambda:path/2015-03-31/functions/arn:aws:lambda:ap-southeast-2:441025416422:function:apex_hello/invocations"
}

# Lambda
resource "aws_lambda_permission" "apigw_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = "arn:aws:lambda:ap-southeast-2:441025416422:function:apex_hello"
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:ap-southeast-2:${var.accountId}:${aws_api_gateway_rest_api.cd_releaser.id}/*/${aws_api_gateway_method.api_post.http_method}${aws_api_gateway_resource.api.path}"
}
