gcp_location = "europe-west1"

prefix = "virgin"

gcp_project_id = "" //Add your GCP Project ID Here 

service_account_display_name = "virgin media task account"

service_account_description = "Single Account Description"

service_accounts_name = ["media-task-account"]

dataset_id = "virginmediadataset"

dataset_name = "vmo2_tech_test"

default_table_expiration_ms = 3600000

dataset_description = "Dataset Description"

cluster_name = "virginmedia-task"

vpc_network_name = "virginmedia-task"

vpc_subnetwork_name = "virginmedia-task"

vpc_subnetwork_cidr_range = "10.0.16.0/20"

cluster_secondary_range_name = "pods"

cluster_secondary_range_cidr = "10.16.0.0/12"

services_secondary_range_name = "services"

services_secondary_range_cidr = "10.1.0.0/20"

daily_maintenance_window_start_time = "03:00"

master_ipv4_cidr_block = "172.16.0.0/28"

table_dataset_labels = {
  env = "dev"
}

bigquery_role_assignment = {         # dataset name
  role = "roles/bigquery.dataEditor" # gcp role
  user = "outlandersafari@gmail.com" # google email address of user
}

master_authorized_networks_cidr_blocks = [
  {
    cidr_block   = "0.0.0.0/0"
    display_name = "default"
  }
]

node_pools = [
  {
    name                       = "node1"
    initial_node_count         = 1
    autoscaling_min_node_count = 1
    autoscaling_max_node_count = 3
    management_auto_upgrade    = true
    management_auto_repair     = true
    node_config_machine_type   = "n1-standard-1"
    node_config_disk_type      = "pd-standard"
    node_config_disk_size_gb   = 20
    node_config_preemptible    = true
  },
  {
    name                       = "node2"
    initial_node_count         = 3
    autoscaling_min_node_count = 1
    autoscaling_max_node_count = 1
    management_auto_upgrade    = true
    management_auto_repair     = true
    node_config_machine_type   = "n1-standard-1"
    node_config_disk_type      = "pd-standard"
    node_config_disk_size_gb   = 20
    node_config_preemptible    = false
  }
]
