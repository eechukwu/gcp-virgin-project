locals {
  gcp_location_parts = split("-", var.gcp_location)
  gcp_region         = format("%s-%s", local.gcp_location_parts[0], local.gcp_location_parts[1])

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


resource "google_bigquery_dataset" "main" {
  dataset_id                  = var.dataset_id
  friendly_name               = var.dataset_name
  description                 = var.description
  location                    = var.gcp_location
  delete_contents_on_destroy  = var.delete_contents_on_destroy
  default_table_expiration_ms = var.default_table_expiration_ms
  project                     = var.gcp_project_id
  labels                      = var.dataset_labels

  dynamic "default_encryption_configuration" {
    for_each = var.encryption_key == null ? [] : [var.encryption_key]
    content {
      kms_key_name = var.encryption_key
    }
  }

  dynamic "access" {
    for_each = var.access
    content {
      role           = lookup(local.iam_to_primitive, access.value.role, access.value.role)
      domain         = lookup(access.value, "domain", "")
      group_by_email = lookup(access.value, "group_by_email", "")
      user_by_email  = lookup(access.value, "user_by_email", "")
      special_group  = lookup(access.value, "special_group", "")
    }
  }
}

resource "google_bigquery_dataset_access" "main" {
  dataset_id     = var.dataset_id
  domain         = var.domain
  group_by_email = var.group_by_email
  iam_member     = var.iam_member
  project        = var.project
  role           = var.role
  special_group  = var.special_group
  user_by_email  = var.user_by_email

  dynamic "timeouts" {
    for_each = var.timeouts
    content {
      create = timeouts.value["create"]
      delete = timeouts.value["delete"]
    }
  }

  depends_on = [
    google_bigquery_dataset.main
  ]

}



