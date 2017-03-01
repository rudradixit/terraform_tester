provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

variable "access_key" {}
variable "secret_key" {}
variable "region" {}

# IAM role for the lambdas to execute
resource "aws_iam_role" "terraform_tester_iam" {
  name = "terraform_tester_iam"
  assume_role_policy = "${file("lambda-role.json")}"
}

# Lambdas definition
resource "aws_lambda_function" "terraform_tester_lambdas" {
  filename = "../target/terraform_tester.jar"
  function_name = "terraform_tester"
  role = "${aws_iam_role.terraform_tester_iam.arn}"
  handler = "com.corindiano.aws.terraform_tester.Main"
  runtime = "java8"
  source_code_hash = "${base64sha256(file("../target/terraform_tester.jar"))}"
}

# API Gateway definition
resource "aws_api_gateway_rest_api" "terraform_tester_api" {
  name = "terraform_tester_api"
  description = "API for the zodiac-emails project"
  depends_on = ["aws_lambda_function.terraform_tester_lambdas"]
}

# API Gateway resource (aka endpoint) definition
resource "aws_api_gateway_resource" "terraform_tester_api_resource" {
  rest_api_id = "${aws_api_gateway_rest_api.terraform_tester_api.id}"
  parent_id = "${aws_api_gateway_rest_api.terraform_tester_api.root_resource_id}"
  path_part = "emails"
}

# API Gateway resource's method definition
resource "aws_api_gateway_method" "terraform_tester_get_method" {
  rest_api_id = "${aws_api_gateway_rest_api.terraform_tester_api.id}"
  resource_id = "${aws_api_gateway_resource.terraform_tester_api_resource.id}"
  http_method = "GET"
  authorization = "NONE"

  request_parameters = {
    "method.request.path.requestId" = true
  }
}

# Integrate the lambdas with the API endpoint
resource "aws_api_gateway_integration" "terraform_tester_integration" {
  rest_api_id = "${aws_api_gateway_rest_api.terraform_tester_api.id}"
  resource_id = "${aws_api_gateway_resource.terraform_tester_api_resource.id}"
  http_method = "${aws_api_gateway_method.terraform_tester_get_method.http_method}"
  type = "AWS"
  integration_http_method = "${aws_api_gateway_method.terraform_tester_get_method.http_method}"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.terraform_tester_lambdas.arn}/invocations"
}

resource "aws_api_gateway_model" "terraform_tester_response_model" {
  rest_api_id = "${aws_api_gateway_rest_api.terraform_tester_api.id}"
  name = "requestId"
  description = "The request ID"
  content_type = "application/json"
  schema = <<EOF
{
  "type": "object"
}
EOF
}

resource "aws_api_gateway_method_response" "200" {
  rest_api_id = "${aws_api_gateway_rest_api.terraform_tester_api.id}"
  resource_id = "${aws_api_gateway_resource.terraform_tester_api_resource.id}"
  http_method = "${aws_api_gateway_method.terraform_tester_get_method.http_method}"
  status_code = "200"

  response_models = {
    "application/json" = "${aws_api_gateway_model.terraform_tester_response_model.name}"
  }
}

resource "aws_api_gateway_integration_response" "terraform_tester_integration_response" {
  rest_api_id = "${aws_api_gateway_rest_api.terraform_tester_api.id}"
  resource_id = "${aws_api_gateway_resource.terraform_tester_api_resource.id}"
  http_method = "${aws_api_gateway_method.terraform_tester_get_method.http_method}"
  status_code = "${aws_api_gateway_method_response.200.status_code}"
  depends_on = ["aws_api_gateway_integration.terraform_tester_integration"]
}

resource "aws_api_gateway_deployment" "production" {
  rest_api_id = "${aws_api_gateway_rest_api.terraform_tester_api.id}"
  stage_name = "api"
  depends_on = ["aws_api_gateway_integration.terraform_tester_integration"]
}