terraform {
  required_version = "= 0.12.13"

  backend s3 {
    bucket         = "aws-terraform-route53-demo-state"
    key            = "terraform.tfstate"
    dynamodb_table = "aws-terraform-route53-demo-state"
    region         = "us-east-1"
  }
}
