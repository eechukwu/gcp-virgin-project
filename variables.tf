variable "gcp_location" {
  type        = string
  description = "The location (region or zone) in which the cluster master will be created"
}

variable "prefix" {
  type = string
}

variable "service_account_display_name" {
  type = string
}

variable "service_account_description" {
  type = string
}

variable "service_accounts_name" {
  type = list(any)
}

variable "table_dataset_labels" {
  description = "A mapping of labels to assign to the table."
  type        = map(string)
}

variable "dataset_name" {
  type = string
}

variable "dataset_description" {
  type = string
}

variable "default_table_expiration_ms" {
  type = number
}

variable "gcp_project_id" {
  type        = string
  description = "The ID of the project in which the resources belong"
}

variable "dataset_id" {
  description = "Unique ID for the dataset being provisioned."
  type        = string
}

variable "cluster_name" {
  type        = string
  description = "The name of the cluster, unique within the project and zone."
}

variable "vpc_network_name" {
  type        = string
  description = "The name of the Google Compute Engine network to which the cluster is connected"
}

variable "vpc_subnetwork_name" {
  type        = string
  description = "The name of the Google Compute Engine subnetwork in which the cluster instances are launched"
}

variable "vpc_subnetwork_cidr_range" {
  type = string
}

variable "cluster_secondary_range_name" {
  type        = string
  description = "Name of the secondary range to be used as for the cluster CIDR block."
}

variable "cluster_secondary_range_cidr" {
  type = string
}

variable "services_secondary_range_name" {
  type        = string
  description = "Name of the secondary range to be used as for the services CIDR block."
}

variable "services_secondary_range_cidr" {
  type = string
}

variable "daily_maintenance_window_start_time" {
  type        = string
  description = "The start time of the 4 hour window for daily maintenance operations RFC3339"
}

variable "master_ipv4_cidr_block" {
  type        = string
  description = "The IP range in CIDR notation to use for the hosted master network."
}

variable "access_private_images" {
  type        = bool
  description = "Whether to create the IAM role for storage.objectViewer, required to access GCR for private container images"
  default     = false
}


variable "bigquery_role_assignment" {
  type = map(any)
}

variable "http_load_balancing_disabled" {
  type        = bool
  default     = false
  description = <<EOF
The status of the HTTP (L7) load balancing controller addon, which makes it 
easy to set up HTTP load balancers for services in a cluster. It is enabled 
by default; set disabled = true to disable.
EOF
}

variable "master_authorized_networks_cidr_blocks" {
  type        = list(map(string))
  description = "Defines up to 20 external networks that can access Kubernetes master through HTTPS"
}

variable "private_endpoint" {
  type        = bool
  default     = false
  description = "Whether the master's internal IP address is used as the cluster endpoint and the public endpoint is disabled"
}

variable "enable_cloud_nat" {
  type        = bool
  default     = true
  description = <<EOF
Whether to enable Cloud NAT. This can be used to allow private cluster nodes to
accesss the internet. Defaults to 'true'.
EOF
}

variable "enable_cloud_nat_logging" {
  type        = bool
  default     = true
  description = <<EOF
Whether the NAT should export logs. Defaults to 'true'.
EOF
}

variable "cloud_nat_logging_filter" {
  type        = string
  default     = "ERRORS_ONLY"
  description = <<EOF
What filtering should be applied to logs for this NAT. Valid values are:
'ERRORS_ONLY', 'TRANSLATIONS_ONLY', 'ALL'. Defaults to 'ERRORS_ONLY'.
EOF
}

variable "private_nodes" {
  type        = bool
  default     = true
  description = <<EOF
Whether nodes have internal IP addresses only. If enabled, all nodes are given
only RFC 1918 private addresses and communicate with the master via private
networking.
EOF
}

variable "pod_security_policy_enabled" {
  type        = bool
  default     = false
  description = <<EOF
A PodSecurityPolicy is an admission controller resource you create that
validates requests to create and update Pods on your cluster. The
PodSecurityPolicy resource defines a set of conditions that Pods must meet to be
accepted by the cluster; when a request to create or update a Pod does not meet
the conditions in the PodSecurityPolicy, that request is rejected and an error
is returned.
If you enable the PodSecurityPolicy controller without first defining and
authorizing any actual policies, no users, controllers, or service accounts can
create or update Pods. If you are working with an existing cluster, you should
define and authorize policies before enabling the controller.
https://cloud.google.com/kubernetes-engine/docs/how-to/pod-security-policies
EOF
}

variable "identity_namespace" {
  type        = string
  default     = ""
  description = <<EOF
The workload identity namespace to use with this cluster. Currently, the only
supported identity namespace is the project's default
'[project_id].svc.id.goog'.
https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity
EOF
}

variable "node_pools" {
  type        = list(map(string))
  description = <<EOF
The list of node pool configurations, each can include:
name - The name of the node pool, which will be suffixed with '-pool'.
Defaults to pool number in the Terraform list, starting from 1.
initial_node_count - The initial node count for the pool. Changing this will
force recreation of the resource. Defaults to 1.
autoscaling_min_node_count - Minimum number of nodes in the NodePool. Must be
>=0 and <= max_node_count. Defaults to 2.
autoscaling_max_node_count - Maximum number of nodes in the NodePool. Must be
>= min_node_count. Defaults to 3.
management_auto_repair - Whether the nodes will be automatically repaired.
Defaults to 'true'.
management_auto_upgrade - Whether the nodes will be automatically upgraded.
Defaults to 'true'.
version - The Kubernetes version for the nodes in this pool. Note that if this
field is set the 'management_auto_upgrade' will be overriden and set to 'false'.
This is to avoid both options fighting on what the node version should be. While
a fuzzy version can be specified, it's recommended that you specify explicit
versions as Terraform will see spurious diffs when fuzzy versions are used. See
the 'google_container_engine_versions' data source's 'version_prefix' field to
approximate fuzzy versions in a Terraform-compatible way.
node_config_machine_type - The name of a Google Compute Engine machine type.
Defaults to n1-standard-1. To create a custom machine type, value should be
set as specified here:
https://cloud.google.com/compute/docs/reference/rest/v1/instances#machineType
node_config_disk_type - Type of the disk attached to each node (e.g.
'pd-standard' or 'pd-ssd'). Defaults to 'pd-standard'
node_config_disk_size_gb - Size of the disk attached to each node, specified
in GB. The smallest allowed disk size is 10GB. Defaults to 100GB.
node_config_preemptible - Whether or not the underlying node VMs are
preemptible. See the official documentation for more information. Defaults to
false. https://cloud.google.com/kubernetes-engine/docs/how-to/preemptible-vms
EOF

}


