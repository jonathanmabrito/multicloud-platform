module "remote_state" {
  source      = "../../../tfm/0-remotestate/" #github.com/genesys/multicloud-platform.git//gcp-gke/tfm/0-remotestate?ref=master
  name        = "gts-multicloud-pe-dev-tf-statefiles"
  location    = "us-west1" 
}


terraform {
  backend "gcs" {
    bucket = "gts-multicloud-pe-dev-tf-statefiles" #Replace with the name of the bucket created above
    prefix = "base-state" #creates a new folder
  }
}


provider "google" {
  project = "gts-multicloud-pe-dev"
}

terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "3.52.0"
    }
  }

  required_version = "= 1.0.11"
}