// El modulo
resource "aws_api_gateway_rest_api" "ApiUsers" {
  name        = "Users Api"
  description = "this API exist to manage the request from the teacher's page"
}

# --- RECURSOS ---

# /register
resource "aws_api_gateway_resource" "RegisterResource" {
  rest_api_id = aws_api_gateway_rest_api.ApiUsers.id
  parent_id   = aws_api_gateway_rest_api.ApiUsers.root_resource_id
  path_part   = "register"
}

# /login
resource "aws_api_gateway_resource" "LoginResource" {
  rest_api_id = aws_api_gateway_rest_api.ApiUsers.id
  parent_id   = aws_api_gateway_rest_api.ApiUsers.root_resource_id
  path_part   = "login"
}

# /profile
resource "aws_api_gateway_resource" "ProfileResource" {
  rest_api_id = aws_api_gateway_rest_api.ApiUsers.id
  parent_id   = aws_api_gateway_rest_api.ApiUsers.root_resource_id
  path_part   = "profile"
}

# /profile/{user_id}
resource "aws_api_gateway_resource" "UpdateResource" {
  rest_api_id = aws_api_gateway_rest_api.ApiUsers.id
  parent_id   = aws_api_gateway_resource.ProfileResource.id
  path_part   = "{user_id}"
}

# /profile/{user_id}/avatar (NUEVO: Para cumplir con el POST del avatar)
resource "aws_api_gateway_resource" "AvatarResource" {
  rest_api_id = aws_api_gateway_rest_api.ApiUsers.id
  parent_id   = aws_api_gateway_resource.UpdateResource.id
  path_part   = "avatar"
}

locals {
  cors_resources = {
    register       = aws_api_gateway_resource.RegisterResource.id
    login          = aws_api_gateway_resource.LoginResource.id
    profile_user   = aws_api_gateway_resource.UpdateResource.id
    profile_avatar = aws_api_gateway_resource.AvatarResource.id
  }
}

// Los endpoints

resource "aws_api_gateway_method" "UserRegisterPost" { //register
  resource_id   = aws_api_gateway_resource.RegisterResource.id
  rest_api_id   = aws_api_gateway_rest_api.ApiUsers.id
  http_method   = "POST"
  authorization = "NONE" // lambda autorizer
}

resource "aws_api_gateway_method" "UserLoginPost" { //login
  resource_id   = aws_api_gateway_resource.LoginResource.id
  rest_api_id   = aws_api_gateway_rest_api.ApiUsers.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "UserUpdatePut" { //update
  resource_id   = aws_api_gateway_resource.UpdateResource.id
  rest_api_id   = aws_api_gateway_rest_api.ApiUsers.id
  http_method   = "PUT"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "UserUploadAvatarPost" { //upload avatar
  resource_id   = aws_api_gateway_resource.AvatarResource.id
  rest_api_id   = aws_api_gateway_rest_api.ApiUsers.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "UserProfileGet" { // get profile
  resource_id   = aws_api_gateway_resource.UpdateResource.id
  rest_api_id   = aws_api_gateway_rest_api.ApiUsers.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "CorsOptions" {
  for_each = local.cors_resources

  rest_api_id   = aws_api_gateway_rest_api.ApiUsers.id
  resource_id   = each.value
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "CorsOptions" {
  for_each = local.cors_resources

  rest_api_id = aws_api_gateway_rest_api.ApiUsers.id
  resource_id = each.value
  http_method = aws_api_gateway_method.CorsOptions[each.key].http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "CorsOptions" {
  for_each = local.cors_resources

  rest_api_id = aws_api_gateway_rest_api.ApiUsers.id
  resource_id = each.value
  http_method = aws_api_gateway_method.CorsOptions[each.key].http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "CorsOptions" {
  for_each = local.cors_resources

  rest_api_id = aws_api_gateway_rest_api.ApiUsers.id
  resource_id = each.value
  http_method = aws_api_gateway_method.CorsOptions[each.key].http_method
  status_code = aws_api_gateway_method_response.CorsOptions[each.key].status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,Authorization'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,PUT,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }

  depends_on = [aws_api_gateway_integration.CorsOptions]
}

// secrets

resource "aws_secretsmanager_secret" "password_secret" {
  name = "banking/password-secret"
}

resource "aws_secretsmanager_secret_version" "password_secret_val" {
  secret_id     = aws_secretsmanager_secret.password_secret.id
  secret_string = "clave-super-secreta-y-bien-chida"
}

// DynamoDB

resource "aws_dynamodb_table" "usersTable" {
  name         = var.user-table
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "uuid"


  attribute {
    name = "uuid"
    type = "S"
  }

  attribute {
    name = "email"
    type = "S"
  }

  # Mantenemos este GSI para el método findByEmail de tu repositorio
  global_secondary_index {
    name            = "EmailIndex"
    hash_key        = "email"
    projection_type = "ALL"
  }

  lifecycle {
    prevent_destroy = false
    ignore_changes = [
      read_capacity,
      write_capacity
    ]
  }
}

// S3

resource "aws_s3_bucket" "user_avatars" {
  bucket        = var.USER_AVATARS_BUCKET
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "avatars_block" {
  bucket = aws_s3_bucket.user_avatars.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_iam_role_policy" "lambda_avatar_combined_policy" {
  name = "lambda_avatar_combined_policy"
  role = aws_iam_role.i_am_upload_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["s3:PutObject"]
        Resource = "${aws_s3_bucket.user_avatars.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:UpdateItem",
          "dynamodb:GetItem"
        ]
        Resource = "arn:aws:dynamodb:${var.region}:${data.aws_caller_identity.current.account_id}:table/${var.user-table}"
      }
    ]
  })
}

locals {
  notification_queue_url = var.notification_queue_url != null ? var.notification_queue_url : ""
}

//Lambdas

//register
resource "aws_lambda_function" "userRegisterLambdaCmd" {
  filename         = var.userLambdaRegisterFileNameCmd
  function_name    = var.userLambdaRegisterNameCmd
  handler          = var.userLambdaRegisterHandlerCmd
  runtime          = "nodejs20.x"
  timeout          = 900
  memory_size      = 256
  role             = aws_iam_role.i_am_Register_lambda.arn
  source_code_hash = data.archive_file.aws_lambda_function_register_file.output_base64sha256

  environment {
    variables = {
      "region"                 = var.region,
      "USER_TABLE"             = var.user-table
      "NOTIFICATION_QUEUE_URL" = local.notification_queue_url
    }
  }

  depends_on = [aws_iam_role_policy_attachment.lambda_basic_register_execution,
  data.archive_file.aws_lambda_function_register_file]
}

resource "aws_iam_role" "i_am_Register_lambda" {
  name               = "ApiPlanLambdaExecution_register"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_basic_register_execution" {
  role       = aws_iam_role.i_am_Register_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_register_dynamo" {
  name   = "lambdaDynamoDbUser_register"
  role   = aws_iam_role.i_am_Register_lambda.id
  policy = data.aws_iam_policy_document.lambda_permissions.json
}

resource "aws_iam_role_policy" "lambda_register_sqs" {
  count = var.notification_queue_arn != null ? 1 : 0

  name = "lambda-register-sqs"
  role = aws_iam_role.i_am_Register_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["sqs:SendMessage"]
        Resource = var.notification_queue_arn
      }
    ]
  })
}


//login
resource "aws_lambda_function" "userLoginLambdaCmd" {
  filename         = var.userLambdaLoginFileNameCmd
  function_name    = var.userLambdaLoginNameCmd
  handler          = var.userLambdaLoginHandlerCmd
  runtime          = "nodejs20.x"
  timeout          = 900
  memory_size      = 256
  role             = aws_iam_role.i_am_login_lambda.arn
  source_code_hash = data.archive_file.aws_lambda_function_login_file.output_base64sha256

  environment {
    variables = {
      "region"                 = var.region,
      "USER_TABLE"             = var.user-table
      "NOTIFICATION_QUEUE_URL" = local.notification_queue_url
    }
  }

  depends_on = [aws_iam_role_policy_attachment.lambda_basic_login_execution,
  data.archive_file.aws_lambda_function_login_file]
}

resource "aws_iam_role" "i_am_login_lambda" {
  name               = "ApiPlanLambdaExecution_login"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_basic_login_execution" {
  role       = aws_iam_role.i_am_login_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_login_dynamo" {
  name   = "lambdaDynamoDbUser_login"
  role   = aws_iam_role.i_am_login_lambda.id
  policy = data.aws_iam_policy_document.lambda_permissions.json
}

resource "aws_iam_role_policy" "lambda_login_sqs" {
  count = var.notification_queue_arn != null ? 1 : 0

  name = "lambda-login-sqs"
  role = aws_iam_role.i_am_login_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["sqs:SendMessage"]
        Resource = var.notification_queue_arn
      }
    ]
  })
}

resource "aws_iam_role_policy" "lambda_login_secrets" {
  name = "lambda_secrets_access_login"
  role = aws_iam_role.i_am_login_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "secretsmanager:GetSecretValue"
        Resource = "${aws_secretsmanager_secret.password_secret.arn}"
      }
    ]
  })
}

//update

resource "aws_lambda_function" "userupdateLambdaCmd" {
  filename         = var.userLambdaUpdateFileNameCmd
  function_name    = var.userLambdaUpdateNameCmd
  handler          = var.userLambdaUpdateHandlerCmd
  runtime          = "nodejs20.x"
  timeout          = 900
  memory_size      = 256
  role             = aws_iam_role.i_am_update_lambda.arn
  source_code_hash = data.archive_file.aws_lambda_function_update_file.output_base64sha256

  environment {
    variables = {
      "region"                 = var.region,
      "USER_TABLE"             = var.user-table
      "NOTIFICATION_QUEUE_URL" = local.notification_queue_url
    }
  }

  depends_on = [aws_iam_role_policy_attachment.lambda_basic_update_execution,
  data.archive_file.aws_lambda_function_update_file]
}

resource "aws_iam_role" "i_am_update_lambda" {
  name               = "ApiPlanLambdaExecution_update"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_basic_update_execution" {
  role       = aws_iam_role.i_am_update_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_update_dynamo" {
  name   = "lambdaDynamoDbUser_update"
  role   = aws_iam_role.i_am_update_lambda.id
  policy = data.aws_iam_policy_document.lambda_permissions.json
}

resource "aws_iam_role_policy" "lambda_update_sqs" {
  count = var.notification_queue_arn != null ? 1 : 0

  name = "lambda-update-sqs"
  role = aws_iam_role.i_am_update_lambda.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["sqs:SendMessage"]
        Resource = var.notification_queue_arn
      }
    ]
  })
}

//upload

resource "aws_lambda_function" "useruploadLambdaCmd" {
  filename         = var.userLambdaUploadFileNameCmd
  function_name    = var.userLambdaUploadNameCmd
  handler          = var.userLambdaUploadHandlerCmd
  runtime          = "nodejs20.x"
  timeout          = 900
  memory_size      = 256
  role             = aws_iam_role.i_am_upload_lambda.arn
  source_code_hash = data.archive_file.aws_lambda_function_upload_file.output_base64sha256

  environment {
    variables = {
      "region"              = var.region,
      "USER_TABLE"          = var.user-table
      "USER_AVATARS_BUCKET" = aws_s3_bucket.user_avatars.id
    }
  }

  depends_on = [aws_iam_role_policy_attachment.lambda_basic_upload_execution,
  data.archive_file.aws_lambda_function_upload_file]
}

resource "aws_iam_role" "i_am_upload_lambda" {
  name               = "ApiPlanLambdaExecution_upload"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_basic_upload_execution" {
  role       = aws_iam_role.i_am_upload_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_upload_dynamo" {
  name   = "lambdaDynamoDbUser_upload"
  role   = aws_iam_role.i_am_upload_lambda.id
  policy = data.aws_iam_policy_document.lambda_permissions.json
}

//Profile

resource "aws_lambda_function" "userprofileLambdaQry" {
  filename         = var.userLambdaProfileFileNameQry
  function_name    = var.userLambdaProfileNameQry
  handler          = var.userLambdaProfileHandlerQry
  runtime          = "nodejs20.x"
  timeout          = 900
  memory_size      = 256
  role             = aws_iam_role.i_am_profile_lambda.arn
  source_code_hash = data.archive_file.aws_lambda_function_profile_file.output_base64sha256

  environment {
    variables = {
      "region"                 = var.region,
      "USER_TABLE"             = var.user-table
      "NOTIFICATION_QUEUE_URL" = local.notification_queue_url
    }
  }

  depends_on = [aws_iam_role_policy_attachment.lambda_basic_profile_execution,
  data.archive_file.aws_lambda_function_profile_file]
}

resource "aws_iam_role" "i_am_profile_lambda" {
  name               = "ApiPlanLambdaExecution_profile"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_basic_profile_execution" {
  role       = aws_iam_role.i_am_profile_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_profile_dynamo" {
  name   = "lambdaDynamoDbUser_profile"
  role   = aws_iam_role.i_am_profile_lambda.id
  policy = data.aws_iam_policy_document.lambda_permissions.json
}

// Integration

//Register

resource "aws_api_gateway_integration" "register_integration" {
  rest_api_id             = aws_api_gateway_rest_api.ApiUsers.id
  resource_id             = aws_api_gateway_resource.RegisterResource.id
  http_method             = aws_api_gateway_method.UserRegisterPost.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.userRegisterLambdaCmd.invoke_arn
}

resource "aws_lambda_permission" "apigw_register" {
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.userLambdaRegisterNameCmd
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.ApiUsers.execution_arn}/*/POST/register"
  depends_on    = [aws_lambda_function.userRegisterLambdaCmd]
}

//login

resource "aws_api_gateway_integration" "login_integration" {
  rest_api_id             = aws_api_gateway_rest_api.ApiUsers.id
  resource_id             = aws_api_gateway_resource.LoginResource.id
  http_method             = aws_api_gateway_method.UserLoginPost.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.userLoginLambdaCmd.invoke_arn
}

resource "aws_lambda_permission" "apigw_login" {
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = var.userLambdaLoginNameCmd
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.ApiUsers.execution_arn}/*/POST/login"
  depends_on    = [aws_lambda_function.userLoginLambdaCmd]
}

// update

resource "aws_api_gateway_integration" "update_integration" {
  rest_api_id             = aws_api_gateway_rest_api.ApiUsers.id
  resource_id             = aws_api_gateway_resource.UpdateResource.id
  http_method             = aws_api_gateway_method.UserUpdatePut.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.userupdateLambdaCmd.invoke_arn
}

resource "aws_lambda_permission" "apigw_update" {
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.userupdateLambdaCmd.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.ApiUsers.execution_arn}/*/PUT/profile/*"

  depends_on = [aws_lambda_function.userupdateLambdaCmd]
}

//get profile

resource "aws_api_gateway_integration" "profile_integration" {
  rest_api_id             = aws_api_gateway_rest_api.ApiUsers.id
  resource_id             = aws_api_gateway_resource.UpdateResource.id
  http_method             = aws_api_gateway_method.UserProfileGet.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.userprofileLambdaQry.invoke_arn
}

resource "aws_lambda_permission" "apigw_profile" {
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.userprofileLambdaQry.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.ApiUsers.execution_arn}/*/GET/profile/*"

  depends_on = [aws_lambda_function.userprofileLambdaQry]
}

// Upload

resource "aws_api_gateway_integration" "upload_integration" {
  rest_api_id             = aws_api_gateway_rest_api.ApiUsers.id
  resource_id             = aws_api_gateway_resource.AvatarResource.id
  http_method             = aws_api_gateway_method.UserUploadAvatarPost.http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.useruploadLambdaCmd.invoke_arn
}

resource "aws_lambda_permission" "apigw_upload" {
  statement_id  = "AllowExecutionFromApiGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.useruploadLambdaCmd.function_name
  principal     = "apigateway.amazonaws.com"

  source_arn = "${aws_api_gateway_rest_api.ApiUsers.execution_arn}/*/POST/profile/*/avatar"

  depends_on = [aws_lambda_function.useruploadLambdaCmd]
}

//Deploy

# El Deployment: Empaqueta todo lo anterior
resource "aws_api_gateway_deployment" "ApiDeployment" {
  depends_on = [
    aws_api_gateway_integration.register_integration,
    aws_api_gateway_integration.login_integration,
    aws_api_gateway_integration.update_integration,
    aws_api_gateway_integration.profile_integration,
    aws_api_gateway_integration.upload_integration,
    aws_api_gateway_integration_response.CorsOptions
  ]

  rest_api_id = aws_api_gateway_rest_api.ApiUsers.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.RegisterResource.id,
      aws_api_gateway_resource.LoginResource.id,
      aws_api_gateway_resource.ProfileResource.id,
      aws_api_gateway_resource.UpdateResource.id,
      aws_api_gateway_resource.AvatarResource.id,
      aws_api_gateway_method.CorsOptions
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "prod" {
  deployment_id = aws_api_gateway_deployment.ApiDeployment.id
  rest_api_id   = aws_api_gateway_rest_api.ApiUsers.id
  stage_name    = "prod"
}

output "apiEndpoint" {
  description = "Api Gateway Endpoints"
  value = {
    # Cambiamos .deployment por .stage.prod
    base_url = "${aws_api_gateway_stage.prod.invoke_url}"

    register = {
      method = "POST"
      url    = "${aws_api_gateway_stage.prod.invoke_url}/register"
    }

    login = {
      method = "POST"
      url    = "${aws_api_gateway_stage.prod.invoke_url}/login"
    }

    profile_get = {
      method = "GET"
      url    = "${aws_api_gateway_stage.prod.invoke_url}/profile/{user_id}"
    }

    profile_update = {
      method = "PUT"
      url    = "${aws_api_gateway_stage.prod.invoke_url}/profile/{user_id}"
    }

    profile_avatar = {
      method = "POST"
      url    = "${aws_api_gateway_stage.prod.invoke_url}/profile/{user_id}/avatar"
    }
  }
}
