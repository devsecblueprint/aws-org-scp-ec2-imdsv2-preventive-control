terraform {
  backend "s3" {
    bucket         = "dsb-scp-terraform-state"
    key            = "02-imdsv2-scp/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}
