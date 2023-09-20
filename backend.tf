#################################################
# メイン
#################################################
terraform {
  required_version = "1.5.4"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {
    bucket = "terraform-tfstate-3423423"
    key    = "terraform.tfstate"
    region = "ap-northeast-1"
  }
}

#################################################
# プロパイダー

#################################################
provider "aws" {
  region = var.region # 東京
}

