# Mappia on Azure

This guide will walk you through installing [Mappia](https://next.mappia.io/) from scratch onto Azure.

## Prerequisites

- [An Azure Account](https://azure.microsoft.com/en-us/free/)
- (Optional) [The `az` cli](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli)
- (Optional) [jq](https://stedolan.github.io/jq/download/)

## Setup

This Terraform module needs two things to start its installation:

- [An Azure Resource Group](#azure-resource-group)
- [A Service Principal](#service-principal) (with owner permissions on the resource group)
 
### Azure Resource group

Create a [Resource Group](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-cli#create-resource-groups) and grab its name.

```bash
RESOURCE_GROUP="demoResourceGroup"
az group create --name $RESOURCE_GROUP --location westus
```

### Service principal 

The [service principal is an Azure identity](https://learn.microsoft.com/en-us/cli/azure/create-an-azure-service-principal-azure-cli#what-is-an-azure-service-principal) created for use with applications, hosted services, and automated tools to access Azure resources. The following command will create a service principal with the necessary permissions on the Resource Group: 

```bash
SERVICE_PRINCIPAL_NAME="myServicePrincipalName"
SUBSCRIPTION_ID=$(az account show --query id -o tsv)
SERVICE_PRINCIPAL=$(az ad sp create-for-rbac --name $SERVICE_PRINCIPAL_NAME \
                         --role owner \
                         --scopes /subscriptions/$SUBSCRIPTION_ID/resourceGroups/$RESOURCE_GROUP)
```

> The service principal that we just created expires in exactly 1 year from creation. [Please remember to rotate the client secret before that time!](https://learn.microsoft.com/en-us/cli/azure/ad/sp/credential?view=azure-cli-latest)

### Resource Providers

For security reasons Azure limits what kinds of resources you can create by default. As a result, you will also need to set your subscription up with certain [resource provider registrations](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-providers-and-types).

```bash
az provider register --namespace Microsoft.KeyVault --wait
```

## Using terraform

To use this terraform module [set the variables safely](https://developer.hashicorp.com/terraform/tutorials/configuration-language/sensitive-variables) in the environment and then create the `main.tf` file:

```bash
mkdir -p my-terraform-project
touch \
  my-terraform-project/main.tf \
  my-terraform-project/variables.tf \
  my-terraform-project/outputs.tf
```

In your `main.tf`, add the following content:

```terraform
module "my-terraform-project" {
  source = "../azure"

  resource_group_name = "demoResourceGroup"
  sp_id = var.mappia_sp_id
  sp_object_id = var.mappia_sp_object_id
  sp_secret = var.mappia_sp_password
  subscription_id =  var.mappia_subscription_id
  sp_tenant_id = var.mappia_sp_tenant_id
}
```

Next, let's add a few outputs to the `outputs.tf` that we will likely want to access once we finish creating our resources. 

```terraform
output "ip_address" {
  value = module.my-terraform-project.ip_address
}

output "full_qualified_domain_name" {
  value = module.my-terraform-project.full_qualified_domain_name
}
```

Now, let's set the appropriate variables for your terraform projects. You can set these via environment variables as below. [You can also use a `.tfvars` file.](https://developer.hashicorp.com/terraform/tutorials/configuration-language/sensitive-variables#set-values-with-a-tfvars-file)

```bash
export TF_VAR_mappia_sp_id="$(echo $SERVICE_PRINCIPAL | jq -r .appId)"
export TF_VAR_mappia_sp_tenant_id="$(echo $SERVICE_PRINCIPAL | jq -r .tenant)"
export TF_VAR_mappia_sp_password="$(echo $SERVICE_PRINCIPAL | jq -r .password)"
export TF_VAR_mappia_sp_object_id="$(az ad sp show --id $TF_VAR_mappia_sp_id --query id -o tsv)"
export TF_VAR_mappia_subscription_id="$(az account show --query id -o tsv)"
```

Finally, let's add the following content to our `variables.tf`:

```terraform
variable "mappia_sp_id" {
  type        = string
  description = "Service principal client Id"
}

variable "mappia_sp_object_id" {
  type        = string
  description = "Service principal object Id"
}

variable "mappia_sp_password" {
  type        = string
  description = "Service principal client secret"
}

variable "mappia_subscription_id" {
  type        = string
  description = "Azure subscription id"
}

variable "mappia_sp_tenant_id" {
  type        = string
  description = "Service principal tenant id"
}
```


Now, we can [init](https://developer.hashicorp.com/terraform/cli/commands/init) within `my-terraform-project`

```bash
cd my-terraform-project
terraform init
```

After initialization, we can now run `terraform plan`. 

```bash
terraform plan
```

You should take a moment to review the output to get a feeling for the resources terraform is creating under the hood.

After you review (and are comfortable with) what we are about to create, you can run `terraform apply`.

```bash
terraform apply
```

> At this point, grab a cup of coffee. This will take about 10 minutes!

Once this has completed, you now have a working Mappia cluster on Azure. You can access the Kubernetes, by running the following commands:

```bash
az aks get-credentials --resource-group $RESOURCE_GROUP --name mappia-aks
kubectl get pods
helm get notes mappia
```

You will be able to get the URL of your Magento 2 store by:

```
terraform output full_qualified_domain_name
```