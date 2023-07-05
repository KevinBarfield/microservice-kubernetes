# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

terraform {

#  cloud {
#
#    organization = "dockerdemo"
#
#    workspaces {
#      name = "demo-eks-tp"
#    }
#  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.64.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0.4"
    }

    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.3.2"
    }
  }

  required_version = "~> 1.3"
}

