module "gke_auth" {
  source = "terraform-google-modules/kubernetes-engine/google//modules/auth"
  project_id    = "gts-multicloud-pe-dev"
  cluster_name  = "cluster02"
  location      = "us-west1"
}

resource "local_file" "kubeconfig" {
  content  = module.gke_auth.kubeconfig_raw
  filename = "${path.module}/kubeconfig"
}

module "ingress_certs" {
  source            = "../../../../tfm/5-ingress-certs/" #github.com/genesys/multicloud-platform.git//gcp-gke/tfm/4-ingress-certs?ref=master
  project_id        = "gts-multicloud-pe-dev"
  environment       = "gts-multicloud-pe-dev" #same value as in 1-network
  domain_name_nginx = "nlb02-uswest1.domain.example.com" #domain.example.com should be same as FQDN in module 1-network
  email             = "jonathan.mabrito@genesys.com"
}

#Kubernetes

data "google_client_config" "provider" {}

data "google_container_cluster" "cluster02" {
  name = "cluster02"
  location = "us-west1"
  project = "gts-multicloud-pe-dev"
}

provider "kubernetes" {
  host = "https://${data.google_container_cluster.cluster02.endpoint}"
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
    host = "https://${data.google_container_cluster.cluster02.endpoint}"
    token = data.google_client_config.provider.access_token
    cluster_ca_certificate = base64decode(
    data.google_container_cluster.cluster02.master_auth[0].cluster_ca_certificate,
    )
    config_path = "${path.module}/kubeconfig"
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
    bucket = "gts-multicloud-pe-dev-tf-statefiles" #Replace with the name of the bucket created above
    prefix = "ingress-certs-cluster02-uswest1-state" #creates a new folder
  }
}