terraform {
  backend "s3" {
    bucket  = "dsb-scp-terraform-state"
    key     = "01-org-bootstrap/terraform.tfstate"
    region  = "us-east-1"
    encrypt = true
  }
}
