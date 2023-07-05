# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

# AWS credentials
# create Terraform Cloud creds set:
# https://developer.hashicorp.com/terraform/tutorials/cloud-get-started/cloud-create-variable-set
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs
#
# ...but also beware there might be a better way:
# https://www.youtube.com/watch?v=IcJc3lDjFSk

#variable "AWS_ACCESS_KEY_ID" {
# type = string
#  default = ""
#}

#variable "AWS_SECRET_ACCESS_KEY" {
#  type = string
#  default = ""
#}