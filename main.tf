terraform {
  required_version = ">= 0.13"

  backend "gcs" {}
}

locals {
  gcp_location_parts = split("-", var.gcp_location)
  gcp_region         = format("%s-%s", local.gcp_location_parts[0], local.gcp_location_parts[1])
}

provider "google" {
  version = "4.53.1"
  project = var.gcp_project_id
  region  = local.gcp_region
}

resource "google_compute_network" "vpc_network" {
  name                    = var.vpc_network_name
  auto_create_subnetworks = "false"
  project                 = var.gcp_project_id
}

resource "google_compute_subnetwork" "vpc_subnetwork" {
  name                     = var.vpc_subnetwork_name
  region                   = local.gcp_region
  project                  = var.gcp_project_id
  ip_cidr_range            = var.vpc_subnetwork_cidr_range
  network                  = var.vpc_network_name
  private_ip_google_access = true
  secondary_ip_range {
    range_name    = var.cluster_secondary_range_name
    ip_cidr_range = var.cluster_secondary_range_cidr
  }
  secondary_ip_range {
    range_name    = var.services_secondary_range_name
    ip_cidr_range = var.services_secondary_range_cidr
  }
  depends_on = [
    google_compute_network.vpc_network,
  ]
}

resource "google_compute_router" "router" {
  count   = var.enable_cloud_nat ? 1 : 0
  name    = format("%s-router", var.cluster_name)
  region  = local.gcp_region
  network = google_compute_network.vpc_network.self_link
}

resource "google_compute_router_nat" "nat" {
  count                              = var.enable_cloud_nat ? 1 : 0
  name                               = format("%s-nat", var.cluster_name)
  router                             = google_compute_router.router[0].name
  region                             = google_compute_router.router[0].region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = var.enable_cloud_nat_logging
    filter = var.cloud_nat_logging_filter
  }
}

module "service_accounts" {
  source        = "terraform-google-modules/service-accounts/google"
  version       = "~> 3.0"
  project_id    = var.gcp_project_id
  prefix        = var.prefix
  names         = var.service_accounts_name
  project_roles = ["${var.gcp_project_id}=>roles/viewer"]
  display_name  = var.service_account_display_name
  description   = var.service_account_description
}

module "cluster" {
  source                                 = "./module/k8scluster"
  gcp_project_id                         = var.gcp_project_id
  cluster_name                           = var.cluster_name
  gcp_location                           = var.gcp_location
  node_pools                             = var.node_pools
  cluster_secondary_range_name           = var.cluster_secondary_range_name
  services_secondary_range_name          = var.services_secondary_range_name
  master_ipv4_cidr_block                 = var.master_ipv4_cidr_block
  access_private_images                  = var.access_private_images
  http_load_balancing_disabled           = var.http_load_balancing_disabled
  master_authorized_networks_cidr_blocks = var.master_authorized_networks_cidr_blocks
  private_nodes                          = var.private_nodes
  private_endpoint                       = var.private_endpoint
  pod_security_policy_enabled            = var.pod_security_policy_enabled
  identity_namespace                     = var.identity_namespace
  vpc_network_name                       = google_compute_network.vpc_network.name
  vpc_subnetwork_name                    = google_compute_subnetwork.vpc_subnetwork.name
  service_account_email                  = module.service_accounts.email
}

module "google-bigquery" {
  source                              = "./module/google-bigquery"
  dataset_id                          = var.dataset_id
  dataset_name                        = var.dataset_name
  description                         = var.dataset_description
  default_table_expiration_ms         = var.default_table_expiration_ms
  dataset_labels                      = var.table_dataset_labels
  daily_maintenance_window_start_time = var.daily_maintenance_window_start_time
  gcp_location                        = var.gcp_location
  role                                = var.bigquery_role_assignment["role"]
  user_by_email                       = var.bigquery_role_assignment["user"]
}

