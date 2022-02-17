terraform {
  backend "s3" {
    bucket = "tfstate-979937110395"
    key    = "state/terraform.tfstate"
    region = "sa-east-1"
  }
}