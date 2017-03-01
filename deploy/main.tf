provider "aws" {
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
  region = "${var.region}"
}

variable "access_key" {}
variable "secret_key" {}
variable "region" {}

data "aws_caller_identity" "current" {}

resource "aws_iam_role" "terraform_tester_iam" {
  name = "terraform_tester_iam"
  assume_role_policy = "${file("lambda-role.json")}"
}

resource "aws_lambda_permission" "lambdaPermission" {
  statement_id = "lambdaPermission"
  action = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.lambda.arn}"
  principal = "apigateway.amazonaws.com"
  source_arn = "arn:aws:execute-api:${var.region}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.api.id}/*"
}

resource "aws_lambda_function" "lambda" {
  filename = "../target/terraform_tester.jar"
  function_name = "terraform_tester"
  role = "${aws_iam_role.terraform_tester_iam.arn}"
  handler = "com.corindiano.aws.terraform_tester.Main"
  runtime = "java8"
  source_code_hash = "${base64sha256(file("../target/terraform_tester.jar"))}"
}

resource "aws_api_gateway_rest_api" "api" {
  name = "zodiacEmailsAPI"
  description = "zodiac-emails API"
  depends_on = ["aws_lambda_function.lambda"]
}

resource "aws_api_gateway_resource" "resource" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  parent_id = "${aws_api_gateway_rest_api.api.root_resource_id}"
  path_part = "emails"
}

resource "aws_api_gateway_resource" "requestId" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  parent_id = "${aws_api_gateway_resource.resource.id}"
  path_part = "{requestId}"
}

resource "aws_api_gateway_method" "get" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.requestId.id}"
  http_method = "POST"
  authorization = "NONE"
  depends_on = ["aws_lambda_permission.lambdaPermission"]
}

resource "aws_api_gateway_method_response" "200" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.requestId.id}"
  http_method = "${aws_api_gateway_method.get.http_method}"
  status_code = "200"
}

resource "aws_api_gateway_integration" "integration" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.requestId.id}"
  http_method = "${aws_api_gateway_method.get.http_method}"
  type = "AWS"
  integration_http_method = "${aws_api_gateway_method.get.http_method}"
  uri = "arn:aws:apigateway:${var.region}:lambda:path/2015-03-31/functions/${aws_lambda_function.lambda.arn}/invocations"
  request_templates = {
    "application/json" = "${file("get_request.json")}"
  }
}

resource "aws_api_gateway_integration_response" "response" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  resource_id = "${aws_api_gateway_resource.requestId.id}"
  http_method = "${aws_api_gateway_method.get.http_method}"
  status_code = "${aws_api_gateway_method_response.200.status_code}"
  response_templates = {
    "application/json" = "${file("get_response.json")}"
  }
}

resource "aws_api_gateway_deployment" "production" {
  rest_api_id = "${aws_api_gateway_rest_api.api.id}"
  stage_name = "api"
  depends_on = ["aws_api_gateway_integration.integration"]
}