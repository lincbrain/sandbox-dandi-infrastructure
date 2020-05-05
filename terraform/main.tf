terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "dandi"

    workspaces {
      name = "dandi-prod"
    }
  }
}

provider "aws" {
  region              = "us-east-2"
  allowed_account_ids = ["278212569472"]
  # Must set AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY envvars
}

provider "heroku" {
  # Must set HEROKU_EMAIL, HEROKU_API_KEY envvars
}
