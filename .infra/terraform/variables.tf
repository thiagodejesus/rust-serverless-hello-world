variable "aws_region" {
  default = "us-east-1"
  type    = string
}

variable "env" {
  default     = "dev"
  type        = string
  description = "The environment to deploy to"

}

variable "aws_profile" {
  default="personal_development"
  type        = string
  description = "The aws profile to use when running terraform"
}

variable "project_name" {
  default = "serverless_rust"
  type        = string
  description = "The name of the project"
}