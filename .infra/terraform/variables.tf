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
  type        = string
  description = "The aws profile to use when running terraform"
}
