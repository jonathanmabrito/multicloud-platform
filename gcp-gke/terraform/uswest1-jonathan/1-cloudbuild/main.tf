module "cloudbuild" {
  source    = "../../../tfm/1-cloudbuild/"
  project_id = "gts-multicloud-pe-dev"
  user      = "serviceAccount:729705515652@cloudbuild.gserviceaccount.com" 
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

terraform {
  backend "gcs" {
    bucket = "gts-multicloud-pe-dev-tf-statefiles" #Replace with the name of the bucket created above
    prefix = "cloudbuild-state" #creates a new folder
  }
}