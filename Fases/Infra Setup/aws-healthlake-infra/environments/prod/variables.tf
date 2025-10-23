variable "region" { default = "eu-west-2" }
variable "env"    { default = "prod" }
variable "name_prefix" { default = "cosight" }
variable "tf_state_bucket" {}
variable "tf_lock_table" { default = "tf-state-lock" }
variable "logs_bucket_name" {}