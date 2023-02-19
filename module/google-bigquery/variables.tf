
variable "dataset_name" {
  description = "Friendly name for the dataset being provisioned."
  type        = string
  default     = null
}

variable "gcp_project_id" {
  type        = string
  description = "The ID of the project in which the resources belong"
  default     = "idyllic-catcher-377416"
}

variable "gcp_location" {
  type        = string
  description = "Location (region or zone) in which the cluster master will be created"
}

variable "dataset_id" {
  description = "Unique ID for the dataset being provisioned."
  type        = string
}

variable "delete_contents_on_destroy" {
  description = "(Optional) If set to true, delete all the tables in the dataset when destroying the resource; otherwise, destroying the resource will fail if tables are present."
  type        = bool
  default     = null
}

variable "deletion_protection" {
  description = "Whether or not to allow Terraform to destroy the instance. Unless this field is set to false in Terraform state, a terraform destroy or terraform apply that would delete the instance will fail"
  type        = bool
  default     = false
}

variable "default_table_expiration_ms" {
  description = "TTL of tables using the dataset in MS"
  type        = number
  default     = null
}

variable "encryption_key" {
  description = "Default encryption key to apply to the dataset. Defaults to null (Google-managed)."
  type        = string
  default     = null
}

variable "dataset_labels" {
  description = "Key value pairs in a map for dataset labels"
  type        = map(string)
  default     = {}
}

variable "access" {
  description = "An array of objects that define dataset access for one or more entities."
  type        = any

  # At least one owner access is required.
  default = [{
    role          = "roles/bigquery.dataOwner"
    special_group = "projectOwners"
  }]
}

variable "description" {
  description = "Dataset description."
  type        = string
  default     = null
}

variable "daily_maintenance_window_start_time" {
  type        = string
  description = "Start time of the 4 hour window for daily maintenance operations"
}

variable "domain" {
  description = "(optional) - A domain to grant access to. Any users signed in with the\ndomain specified will be granted the specified access"
  type        = string
  default     = null
}

variable "group_by_email" {
  description = "(optional) - An email address of a Google Group to grant access to."
  type        = string
  default     = null
}

variable "iam_member" {
  description = "(optional) - Some other type of member that appears in the IAM Policy but isn't a user,\ngroup, domain, or special group. For example: 'allUsers'"
  type        = string
  default     = null
}

variable "project" {
  description = "(optional)"
  type        = string
  default     = null
}

variable "role" {
  description = "(optional) - Describes the rights granted to the user specified by the other\nmember of the access object. Basic, predefined, and custom roles are\nsupported. Predefined roles that have equivalent basic roles are\nswapped by the API to their basic counterparts, and will show a diff\npost-create. See\n[official docs](https://cloud.google.com/bigquery/docs/access-control)."
  type        = string
  default     = null
}

variable "special_group" {
  description = "(optional) - A special group to grant access to. Possible values include:\n\n\n* 'projectOwners': Owners of the enclosing project.\n\n\n* 'projectReaders': Readers of the enclosing project.\n\n\n* 'projectWriters': Writers of the enclosing project.\n\n\n* 'allAuthenticatedUsers': All authenticated BigQuery users."
  type        = string
  default     = null
}

variable "user_by_email" {
  description = "(optional) - An email address of a user to grant access to. For example:\nfred@example.com"
  type        = string
  default     = null
}

variable "timeouts" {
  description = "nested block: NestingSingle, min items: 0, max items: 0"
  type = set(object(
    {
      create = string
      delete = string
    }
  ))
  default = []
}

variable "view" {
  description = "nested block: NestingList, min items: 0, max items: 1"
  type = set(object(
    {
      dataset_id = string
      project_id = string
      table_id   = string
    }
  ))
  default = []
}
