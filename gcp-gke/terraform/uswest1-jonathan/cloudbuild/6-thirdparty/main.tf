module "third-party" {
    source  = "../../../../tfm/6-third-party/" #github.com/genesys/multicloud-platform.git//gcp-gke/tfm/5-third-party?ref=master
}


data "google_client_config" "provider" {}

data "google_container_cluster" "cluster02" {
  name     = "cluster02"
  location = "us-west1"
  project  = "gts-multicloud-pe-dev"
}

provider "kubernetes" {
  host  = "https://${data.google_container_cluster.cluster02.endpoint}"
  token = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(
    data.google_container_cluster.cluster02.master_auth[0].cluster_ca_certificate,
  )
}

#Helm

variable "helm_version" {
  default = "v2.9.1"
}
provider "helm" {

  kubernetes {
    host  = "https://${data.google_container_cluster.cluster02.endpoint}"
    token = data.google_client_config.provider.access_token
    cluster_ca_certificate = base64decode(
      data.google_container_cluster.cluster02.master_auth[0].cluster_ca_certificate,
    )
    config_path = "~/.kube/config"
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

terraform {
    backend "gcs" {
        bucket = "gts-multicloud-pe-dev-tf-statefiles"
        prefix = "thirdparty-cluster02-uswest1-state" #creates a new folder
    }
}