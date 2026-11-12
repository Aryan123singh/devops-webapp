
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

data "aws_instance" "vle8" {
  instance_id = "i-05353580768550f4f"
}

output "instance_id" {
  value = data.aws_instance.vle8.id
}

output "instance_type" {
  value = data.aws_instance.vle8.instance_type
}

output "instance_state" {
  value = data.aws_instance.vle8.instance_state
}

output "availability_zone" {
  value = data.aws_instance.vle8.availability_zone
}
