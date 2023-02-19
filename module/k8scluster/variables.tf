variable "gcp_project_id" {
  type        = string
  description = "The ID of the project in which the resources belong."
}

variable "cluster_name" {
  type        = string
  description = "The name of the cluster, unique within the project and zone"
}

variable "gcp_location" {
  type        = string
  description = "Location (region or zone) in which the cluster master will be created"
}

variable "daily_maintenance_window_start_time" {
  type        = string
  description = "The start time of the 4 hour window for daily maintenance operations RFC3339"
  default     = "03:00"
}

variable "service_account_email" {
  type        = string
  description = "The service account to use while creating the K8S cluster"
}

variable "vpc_network_name" {
  type        = string
  description = "The name of the Google Compute Engine network to which the cluster is connected"
}

variable "vpc_subnetwork_name" {
  type        = string
  description = "The name of the Google Compute Engine subnetwork in which the cluster instances are launched"
}

variable "cluster_secondary_range_name" {
  type        = string
  description = "The name of the secondary range to be used as for the cluster CIDR block"
}

variable "services_secondary_range_name" {
  type        = string
  description = "The name of the secondary range to be used as for the services CIDR block"
}

variable "master_ipv4_cidr_block" {
  type        = string
  default     = "172.16.0.0/28"
  description = "The IP range in CIDR notation to use for the hosted master network."
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

variable "access_private_images" {
  type        = bool
  default     = false
  description = <<EOF
Whether to create the IAM role for storage.objectViewer, required to access
GCR for private container images.
EOF
}

variable "http_load_balancing_disabled" {
  type    = bool
  default = false

  description = <<EOF
The status of the HTTP (L7) load balancing controller addon, which makes it 
easy to set up HTTP load balancers for services in a cluster. It is enabled 
by default; set disabled = true to disable.
EOF
}

variable "master_authorized_networks_cidr_blocks" {
  type = list(map(string))

  default = [
    {
      cidr_block   = "0.0.0.0/0"
      display_name = "default"
    },
  ]

  description = <<EOF
Defines up to 20 external networks that can access Kubernetes master
through HTTPS.
EOF
}

variable "min_master_version" {
  type = string

  default = ""

  description = <<EOF
The minimum version of the master. GKE will auto-update the master to new
versions, so this does not guarantee the current master version. Use the
read-only 'master_version' field to obtain that. If unset, the cluster's
version will be set by GKE to the version of the most recent official release
(which is not necessarily the latest version). Most users will find the
'google_container_engine_versions' data source useful - it indicates which
versions are available. If you intend to specify versions manually, the
docs describe the various acceptable formats for this field.

This can be a specific version such as '1.16.8-gke.N', a patch or minor version
such as '1.X', the latest available version with 'latest', or the default
version with '-'.

Creating or upgrading a cluster by specifying the version as latest does not
provide automatic upgrades.

This option is overriden if a 'release_channel' is set.

https://cloud.google.com/kubernetes-engine/versioning-and-upgrades#specifying_cluster_version
EOF
}

variable "release_channel" {
  type = string

  default = "REGULAR"

  description = <<EOF
Kubernetes releases updates often, to deliver security updates, fix known
issues, and introduce new features. Release channels provide control over how
often clusters are automatically updated, and offer customers the ability to
balance between stability and functionality of the version deployed in the
cluster.

When you enroll a cluster in a release channel, Google automatically manages the
version and upgrade cadence for the cluster and its node pools. All channels
offer supported releases of GKE and are considered GA (although individual
features may not always be GA, as marked). The Kubernetes releases in these
channels are official Kubernetes releases and include both GA and beta
Kubernetes APIs (as marked). New Kubernetes versions are first released to the
Rapid channel, and over time will be promoted to the Regular, and Stable
channel. This allows you to subscribe your cluster to a channel that meets your
business, stability, and functionality needs.

This can be one of 'RAPID', 'REGULAR', or 'STABLE'.

Setting a release channel overrides the 'min_master_version' option.

https://cloud.google.com/kubernetes-engine/docs/concepts/release-channels
EOF
}

variable "authenticator_security_group" {
  type = string

  default = ""

  description = <<EOF
The name of the RBAC security group for use with Google security groups in
Kubernetes RBAC. Group name must be in format
gke-security-groups@yourdomain.com.
EOF
}

variable "stackdriver_logging" {
  type    = bool
  default = true

  description = <<EOF
Whether Stackdriver Kubernetes logging is enabled. This should only be set to
"false" if another logging solution is set up.
EOF
}

variable "stackdriver_monitoring" {
  type    = bool
  default = true

  description = <<EOF
Whether Stackdriver Kubernetes monitoring is enabled. This should only be set to
"false" if another monitoring solution is set up.
EOF
}

variable "private_endpoint" {
  type    = bool
  default = false

  description = <<EOF
Whether the master's internal IP address is used as the cluster endpoint and the
public endpoint is disabled.
EOF
}

variable "private_nodes" {
  type    = bool
  default = true

  description = <<EOF
Whether nodes have internal IP addresses only. If enabled, all nodes are given
only RFC 1918 private addresses and communicate with the master via private
networking.
EOF
}

variable "pod_security_policy_enabled" {
  type = bool

  default = false

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
  type = string

  default = ""

  description = <<EOF
The workload identity namespace to use with this cluster. Currently, the only
supported identity namespace is the project's default
'[project_id].svc.id.goog'.
https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity
EOF
}
