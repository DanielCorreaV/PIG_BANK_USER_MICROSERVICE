variable "region" {
  type = string
  default = "us-east-1"
}

variable "user-table" {
  type =  string
  default = "users"
}

variable "USER_AVATARS_BUCKET" {
  type = string
  default = "my-banking-avatars"
}

//register

variable "userLambdaRegisterNameCmd" {
  type = string
  default = "user-register-cmd-v1"
}

variable "userLambdaRegisterHandlerCmd" {
    type = string
    default = "register-user-handler.handler" 
}

variable "userLambdaRegisterFileNameCmd" {
  type = string
  default = "archives/register-user-handler.zip"
}


//update

variable "userLambdaUpdateNameCmd" {
  type = string
  default = "user-update-cmd-v1"
}

variable "userLambdaUpdateHandlerCmd" {
    type = string
    default = "update-user-handler.handler" 
}

variable "userLambdaUpdateFileNameCmd" {
  type = string
  default = "archives/update-user-handler.zip"
}

//Login

variable "userLambdaLoginNameCmd" {
  type = string
  default = "user-login-cmd-v1"
}

variable "userLambdaLoginHandlerCmd" {
    type = string
    default = "login-user-handler.handler" 
}

variable "userLambdaLoginFileNameCmd" {
  type = string
  default = "archives/login-user-handler.zip"
}

//Upload

variable "userLambdaUploadNameCmd" {
  type = string
  default = "user-upload-cmd-v1"
}

variable "userLambdaUploadHandlerCmd" {
    type = string
    default = "upload-avatar-handler.handler" 
}

variable "userLambdaUploadFileNameCmd" {
  type = string
  default = "archives/upload-avatar-handler.zip"
}

//Profile

variable "userLambdaProfileNameQry" {
  type = string
  default = "user-profile-qry-v1"
}

variable "userLambdaProfileHandlerQry" {
    type = string
    default = "get-profile-handler.handler" 
}

variable "userLambdaProfileFileNameQry" {
  type = string
  default = "archives/get-profile-handler.zip"
}

