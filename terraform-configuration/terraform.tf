terraform {
  cloud {
    workspaces {
      name = "octopus"
    }
  }


  required_providers {
    aws = {
      source = "hashicorp/aws"

      version = "~> 5.00"

    }
  }


  required_version = ">= 0.14.9"

}

