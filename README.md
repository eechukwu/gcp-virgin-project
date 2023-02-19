# Terraform

This repository makes it easy for anyone to create a K8S cluster, VPC, and BigQuery dataset that is secure and follows GCP best practices.

The resources listed below will be created

- Provision a regional `private` K8s cluster on GKE
- Provision a dedicated service account for the K8s cluster
- Provision a `new VPC` for the cluster
- Provision the subnet in the `London` region
- Set up two node-pools
- Creates a NAT gateway to enable outbound internet access to the private cluster without the need for external IP addresses.
- Creates a new big query dataset called vmo2_tech_test
- Create a local module that assigns specific roles to specific datasets using the google_bigquery_dataset_access resource.

## Usage

The repository requires an existing Google Cloud Account and a GCP bucket to store our terraform state files. 
The repository  allows the resources to be extensively customised using dev.tfvars file.[`dev.tfvars`](dev.tfvars).
The repository itself is located in the root of this repository, and is designed to be used as part of a larger Terraform project.

NOTE: Please remember to update the gcp_project_id in the dev.tfvars file.[`dev.tfvars`](dev.tfvars) with you Project ID. Also you need to manual create a bucket for the terraform state file. 



```
module "cluster" {
  source  = "./module/k8scluster"

  # insert the 9 required variables here
}

module "google-bigquery" {
    source = "./module/google-bigquery"
}
```

```
Run these command from the root folder after amending the dev.tfvars to suit your needs.
terraform init    
terraform plan -var-file=dev.tfvars  
terraform validate
terraform apply -var-file=dev.tfvars  
```
