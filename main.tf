# main.tf

provider "google" {
  credentials = file("path/to/your/gcp/credentials.json")
  project     = var.project_id
  region      = var.region
}

resource "google_container_cluster" "k8s_cluster" {
  name     = var.cluster_name
  location = var.region

  remove_default_node_pool = true

  initial_node_count = 1

  node_pool {
    name       = "default-pool"
    machine_type = "n1-standard-1"
    disk_size_gb = 100
    min_count    = 1
    max_count    = 5  # Adjust max_count based on your requirements
  }

  master_auth {
    username = ""
    password = ""
  }
}
