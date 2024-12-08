variable "resource_group_name" {
  description = "the name of the resource group"
  type        = string
}

variable "resource_group_location" {
  description = "the location of the resource group"
  type        = string
}


variable "app_service_plan_name" {
  description = "the name of the app service plan"
  type        = string
}

variable "web_app_service_name" {
  description = "the name of fhe app"
  type        = string
}

variable "sql_server_name" {
  description = "the name of fhe sql server"
  type        = string
}

variable "sql_database_name" {
  description = "the name of fhe sql db"
  type        = string
}

variable "sql_admin_user" {
  description = "the name of fhe sql user"
  type        = string
}

variable "sql_admin_user_pass" {
  description = "the pass of fhe sql user"
  type        = string
}

variable "firewall_rule" {
  description = "the name of fhe firewall rule"
  type        = string
}

variable "github_repo" {
  description = "the location of fhe github repo"
  type        = string
}
