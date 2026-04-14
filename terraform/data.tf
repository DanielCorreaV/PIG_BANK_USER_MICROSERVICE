data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

data "aws_caller_identity" "current" {}


data "aws_iam_policy_document" "lambda_permissions" {
  // Permisos para DynamoDB 
  statement {
    effect = "Allow"
    actions = [
      "dynamodb:GetItem",
      "dynamodb:PutItem",
      "dynamodb:UpdateItem",
      "dynamodb:Query",
      "dynamodb:Scan"
    ]
    resources = [
      "${aws_dynamodb_table.usersTable.arn}",
      "${aws_dynamodb_table.usersTable.arn}/index/*"
    ]
  }

  // Permisos para S3 
  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
      "s3:PutObjectAcl"
    ]
    resources = ["arn:aws:s3:::my-banking-avatars/*"]
  }

  // Permisos para Secrets Manager
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue"
    ]
    resources = ["*"]
  }

  // Permisos de Logs
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }
}

data "archive_file" "aws_lambda_function_register_file" {
  type        = "zip"
  source_file = "${path.module}/../app/dist/register-user-handler.js"
  output_path = "${path.module}/${var.userLambdaRegisterFileNameCmd}"
}

data "archive_file" "aws_lambda_function_update_file" {
  type        = "zip"
  source_file = "${path.module}/../app/dist/update-user-handler.js"
  output_path = "${path.module}/${var.userLambdaUpdateFileNameCmd}"
}

data "archive_file" "aws_lambda_function_login_file" {
  type        = "zip"
  source_file = "${path.module}/../app/dist/login-user-handler.js"
  output_path = "${path.module}/${var.userLambdaLoginFileNameCmd}"
}

data "archive_file" "aws_lambda_function_upload_file" {
  type        = "zip"
  source_file = "${path.module}/../app/dist/upload-avatar-handler.js"
  output_path = "${path.module}/${var.userLambdaUploadFileNameCmd}"
}

data "archive_file" "aws_lambda_function_profile_file" {
  type        = "zip"
  source_file = "${path.module}/../app/dist/get-profile-handler.js"
  output_path = "${path.module}/${var.userLambdaProfileFileNameQry}"
}