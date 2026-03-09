// El modulo
resource "aws_api_gateway_rest_api" "ApiUsers" {
  name = "Users Api"
  description = "this API exist to manage the request from the teacher's page"
}

resource "aws_api_gateway_resource" "UsersResource" {
  rest_api_id = aws_api_gateway_rest_api.ApiUsers
  parent_id = aws_api_gateway_rest_api.ApiUsers.root_resource_id
  path_part = "users"
}

// Los endpoints

resource "aws_api_gateway_method" "UserRegisterPost" { //register
  resource_id = aws_api_gateway_resource.UsersResource.id
  rest_api_id = aws_api_gateway_rest_api.ApiUsers.id
  http_method = "POST"
  authorization = "NONE" // lambda autorizer
}

resource "aws_api_gateway_method" "UserLoginPost" { //login
    resource_id = aws_api_gateway_resource.UsersResource.id
    rest_api_id = aws_api_gateway_rest_api.ApiUsers.id
    http_method = "POST"
    authorization = "NONE" 
}

resource "aws_api_gateway_method" "UserUpdatePut" { //update
    resource_id = aws_api_gateway_resource.UsersResource.id
    rest_api_id = aws_api_gateway_rest_api.ApiUsers.id
    http_method = "PUT"
    authorization = "NONE" 
}

resource "aws_api_gateway_method" "UserUploadAvatarPost" { //upload avatar
    resource_id = aws_api_gateway_resource.UsersResource.id
    rest_api_id = aws_api_gateway_rest_api.ApiUsers.id
    http_method = "POST"
    authorization = "NONE" 
}

resource "aws_api_gateway_method" "UserProfileGet" { // get profile
    resource_id = aws_api_gateway_resource.UsersResource.id
    rest_api_id = aws_api_gateway_rest_api.ApiUsers.id
    http_method = "GET"
    authorization = "NONE" 
}

// DynamoDB

resource "aws_dynamodb_table" "usersTable" {
    name = var.user-table
    billing_mode = "PAY_PER_REQUEST"
    read_capacity = 20
    write_capacity = 20
    hash_key = "uuid"
    range_key = "document"

    attribute {
    name = "uuid"
    type = "S" 
  }

  attribute {
    name = "document"
    type = "S"
  }

  attribute {
    name = "email"
    type = "S"
  }

  # Índice necesario para tu método findByEmail
  global_secondary_index {
    name               = "EmailIndex"
    hash_key           = "email"
    projection_type    = "ALL"
  }

    lifecycle {
      prevent_destroy = false
      ignore_changes = [ 
        read_capacity,
        write_capacity
      ] 
    }
}


//Lambdas

//register
resource "aws_lambda_function" "userRegisterLambdaCmd" {
  filename = var.userLambdaRegisterFileNameCmd
  function_name = var.userLambdaRegisterNameCmd
  handler = var.userLambdaRegisterHandlerCmd
  runtime = "nodejs20.x"
  timeout = 900
  memory_size = 256
  role = aws_iam_role.i_am_Register_lambda.arn
  source_code_hash = data.archive_file.aws_lambda_function_register_file.output_base64sha256

  environment {
    variables = {
        "region" = var.region,
        "USER_TABLE" = var.user-table
    }
  }

  depends_on = [ aws_iam_role_policy_attachment.lambda_basic_register_execution,
  data.archive_file.aws_lambda_function_register_file ]
}

resource "aws_iam_role" "i_am_Register_lambda" {
  name = "ApiPlanLambdaExecution_register"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_basic_register_execution" {
  role = aws_iam_role.i_am_Register_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_register_dynamo" {
  name = "lambdaDynamoDbUser_register"
  role = aws_iam_role.i_am_Register_lambda.id
  policy = data.aws_iam_policy_document.lambda_permissions.json
}


//login
resource "aws_lambda_function" "userLoginLambdaCmd" {
  filename = var.userLambdaLoginFileNameCmd
  function_name = var.userLambdaLoginNameCmd
  handler = var.userLambdaLoginHandlerCmd
  runtime = "nodejs20.x"
  timeout = 900
  memory_size = 256
  role = aws_iam_role.i_am_Login_lambda.arn
  source_code_hash = data.archive_file.aws_lambda_function_login_file.output_base64sha256

  environment {
    variables = {
        "region" = var.region,
        "USER_TABLE" = var.user-table
    }
  }

  depends_on = [ aws_iam_role_policy_attachment.lambda_basic_login_execution,
  data.archive_file.aws_lambda_function_login_file ]
}

resource "aws_iam_role" "i_am_login_lambda" {
  name = "ApiPlanLambdaExecution_login"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_basic_login_execution" {
  role = aws_iam_role.i_am_login_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_login_dynamo" {
  name = "lambdaDynamoDbUser_login"
  role = aws_iam_role.i_am_login_lambda.id
  policy = data.aws_iam_policy_document.lambda_permissions.json
}

//update

resource "aws_lambda_function" "userupdateLambdaCmd" {
  filename = var.userLambdaUpdateFileNameCmd
  function_name = var.userLambdaUpdateNameCmd
  handler = var.userLambdaUpdateHandlerCmd
  runtime = "nodejs20.x"
  timeout = 900
  memory_size = 256
  role = aws_iam_role.i_am_update_lambda.arn
  source_code_hash = data.archive_file.aws_lambda_function_update_file.output_base64sha256

  environment {
    variables = {
        "region" = var.region,
        "USER_TABLE" = var.user-table
    }
  }

  depends_on = [ aws_iam_role_policy_attachment.lambda_basic_update_execution,
  data.archive_file.aws_lambda_function_update_file ]
}

resource "aws_iam_role" "i_am_update_lambda" {
  name = "ApiPlanLambdaExecution_update"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_basic_update_execution" {
  role = aws_iam_role.i_am_update_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_update_dynamo" {
  name = "lambdaDynamoDbUser_update"
  role = aws_iam_role.i_am_update_lambda.id
  policy = data.aws_iam_policy_document.lambda_permissions.json
}

//upload

resource "aws_lambda_function" "useruploadLambdaCmd" {
  filename = var.userLambdaUploadFileNameCmd
  function_name = var.userLambdaUploadNameCmd
  handler = var.userLambdaUploadHandlerCmd
  runtime = "nodejs20.x"
  timeout = 900
  memory_size = 256
  role = aws_iam_role.i_am_upload_lambda.arn
  source_code_hash = data.archive_file.aws_lambda_function_upload_file.output_base64sha256

  environment {
    variables = {
        "region" = var.region,
        "USER_TABLE" = var.user-table
    }
  }

  depends_on = [ aws_iam_role_policy_attachment.lambda_basic_upload_execution,
  data.archive_file.aws_lambda_function_upload_file ]
}

resource "aws_iam_role" "i_am_upload_lambda" {
  name = "ApiPlanLambdaExecution_upload"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_basic_upload_execution" {
  role = aws_iam_role.i_am_upload_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_upload_dynamo" {
  name = "lambdaDynamoDbUser_upload"
  role = aws_iam_role.i_am_upload_lambda.id
  policy = data.aws_iam_policy_document.lambda_permissions.json
}

//Profile

resource "aws_lambda_function" "userprofileLambdaQry" {
  filename = var.userLambdaProfileFileNameQry
  function_name = var.userLambdaProfileNameQry
  handler = var.userLambdaProfileHandlerQry
  runtime = "nodejs20.x"
  timeout = 900
  memory_size = 256
  role = aws_iam_role.i_am_profile_lambda.arn
  source_code_hash = data.archive_file.aws_lambda_function_profile_file.output_base64sha256

  environment {
    variables = {
        "region" = var.region,
        "USER_TABLE" = var.user-table
    }
  }

  depends_on = [ aws_iam_role_policy_attachment.lambda_basic_profile_execution,
  data.archive_file.aws_lambda_function_profile_file ]
}

resource "aws_iam_role" "i_am_profile_lambda" {
  name = "ApiPlanLambdaExecution_profile"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "lambda_basic_profile_execution" {
  role = aws_iam_role.i_am_profile_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy" "lambda_profile_dynamo" {
  name = "lambdaDynamoDbUser_profile"
  role = aws_iam_role.i_am_profile_lambda.id
  policy = data.aws_iam_policy_document.lambda_permissions.json
}