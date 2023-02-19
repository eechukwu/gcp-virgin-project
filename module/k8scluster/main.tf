terraform {
  required_version = ">= 0.13"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.53.1"
    }
  }
}

locals {
  gcp_location_parts           = split("-", var.gcp_location)
  gcp_region                   = format("%s-%s", local.gcp_location_parts[0], local.gcp_location_parts[1])
  min_master_version           = var.release_channel == "" ? var.min_master_version : ""
  release_channel              = var.release_channel == "" ? [] : [var.release_channel]
  identity_namespace           = var.identity_namespace == "" ? [] : [var.identity_namespace]
  authenticator_security_group = var.authenticator_security_group == "" ? [] : [var.authenticator_security_group]

  iam_to_primitive = {
    "roles/bigquery.dataOwner" : "OWNER"
    "roles/bigquery.dataEditor" : "WRITER"
    "roles/bigquery.dataViewer" : "READER"
  }
}

provider "google" {
  version = "4.53.1"
  project = var.gcp_project_id
  region  = local.gcp_region
}

provider "google-beta" {
  version = "4.53.1"
  project = var.gcp_project_id
  region  = local.gcp_region
}

# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/container_cluster.html
resource "google_container_cluster" "cluster" {
  provider           = google-beta
  location           = var.gcp_location //"my-gke-cluster"
  name               = var.cluster_name //"us-central1"
  min_master_version = local.min_master_version

  dynamic "release_channel" {
    for_each = toset(local.release_channel)

    content {
      channel = release_channel.value
    }
  }

  dynamic "authenticator_groups_config" {
    for_each = toset(local.authenticator_security_group)

    content {
      security_group = authenticator_groups_config.value
    }
  }

  maintenance_policy {
    daily_maintenance_window {
      start_time = var.daily_maintenance_window_start_time
    }
  }

  private_cluster_config {
    enable_private_endpoint = var.private_endpoint
    enable_private_nodes    = var.private_nodes
    master_ipv4_cidr_block  = var.master_ipv4_cidr_block
  }

  pod_security_policy_config {
    enabled = var.pod_security_policy_enabled
  }

  network_policy {
    enabled  = true
    provider = "CALICO"
  }

  addons_config {
    http_load_balancing {
      disabled = var.http_load_balancing_disabled
    }
    network_policy_config {
      disabled = false
    }
  }

  network    = var.vpc_network_name
  subnetwork = var.vpc_subnetwork_name

  ip_allocation_policy {
    cluster_secondary_range_name  = var.cluster_secondary_range_name
    services_secondary_range_name = var.services_secondary_range_name
  }

  remove_default_node_pool = true

  initial_node_count = 1

  master_authorized_networks_config {
    dynamic "cidr_blocks" {
      for_each = var.master_authorized_networks_cidr_blocks
      content {
        cidr_block   = cidr_blocks.value.cidr_block
        display_name = cidr_blocks.value.display_name
      }
    }
  }

  logging_service = var.stackdriver_logging != "false" ? "logging.googleapis.com/kubernetes" : ""

  monitoring_service = var.stackdriver_monitoring != "false" ? "monitoring.googleapis.com/kubernetes" : ""

  timeouts {
    update = "20m"
  }

}

# https://www.terraform.io/docs/providers/google/r/container_node_pool.html
resource "google_container_node_pool" "node_pool" {
  provider = google

  location = google_container_cluster.cluster.location

  count = length(var.node_pools)

  name = format("%s-pool", lookup(var.node_pools[count.index], "name", format("%03d", count.index + 1)))

  cluster = google_container_cluster.cluster.name

  initial_node_count = 3

  autoscaling {
    min_node_count = lookup(var.node_pools[count.index], "autoscaling_min_node_count", 0)

    max_node_count = lookup(var.node_pools[count.index], "autoscaling_max_node_count", 0)
  }

  version = lookup(var.node_pools[count.index], "version", "")

  management {
    auto_repair  = lookup(var.node_pools[count.index], "auto_repair", true)
    auto_upgrade = lookup(var.node_pools[count.index], "version", "") == "" ? lookup(var.node_pools[count.index], "auto_upgrade", true) : false
  }

  node_config {
    machine_type = lookup(
      var.node_pools[count.index],
      "node_config_machine_type",
      "n1-standard-1",
    )

    service_account = var.service_account_email
    disk_size_gb = lookup(
      var.node_pools[count.index],
      "node_config_disk_size_gb",
      100
    )

    disk_type = lookup(
      var.node_pools[count.index],
      "node_config_disk_type",
      "pd-standard",
    )

    preemptible = lookup(
      var.node_pools[count.index],
      "node_config_preemptible",
      false,
    )

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    metadata = {
      disable-legacy-endpoints = "true"
    }
  }

  timeouts {
    update = "20m"
  }
}
