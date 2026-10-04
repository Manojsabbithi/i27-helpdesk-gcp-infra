terraform {
  backend "gcs" {
    bucket = "i27-helpdesk-gcp-dev-lab-tfstate"
    prefix = "terraform/dev"
  }
}
