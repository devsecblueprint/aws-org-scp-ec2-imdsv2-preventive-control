terraform {
  backend "s3" {
    bucket         = "dsb-terraform-state-083281668894"
    key            = "03-ec2-instance/terraform.tfstate"
    region         = "us-east-2"
    encrypt        = true
  }
}
