# variables.tf

variable "project_id" {
  description = "The ID of the Google Cloud Platform (GCP) project."
  type        = string
}

variable "region" {
  description = "The GCP region where resources will be created."
  type        = string
}

variable "cluster_name" {
  description = "The name of the Kubernetes cluster."
  type        = string
}
