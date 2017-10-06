provider "aws" {
  region     = "ap-southeast-2"
  profile    = "serverless"
}

variable "accountId" {
  default = "441025416422"
}
