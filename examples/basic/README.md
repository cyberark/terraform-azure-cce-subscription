# Example: Basic CCE Subscription Onboarding with SIA, SCA and Cloud Discovery

This example demonstrates the minimal configuration required to onboard an Azure subscription to Connect Cloud Environments (CCE) with SIA (Secure Infrastructure Access) enabled. Optionally, SCA (Secure Cloud Access) and Cloud Discovery (for Cloud service entitlements) can be enabled by passing `shared_resources` from the Commons module.

## What This Example Does

* Onboards your Azure subscription to CCE  
* Enables SIA (Secure Infrastructure Access) for VM discovery and privileged access management  
* Optionally enables SCA at subscription scope (when `sca.shared_resources` from Commons is provided)
* Optionally enables Cloud Discovery (for Cloud service entitlements) for the subscription (when `cds.shared_resources` from Commons is provided, see step 2 below)

## Prerequisites

* Azure subscription and Microsoft Entra tenant credentials  
* Idira tenant with CCE  
* Terraform >= 1.8.5  
* Idira `idsec` provider configured - https://registry.terraform.io/providers/cyberark/idsec/latest/docs#example-usage  
* For SCA: run the Commons module first and pass its `sca` output as `shared_resources`
* For Cloud Discovery: run the Commons module with `cds = { enable = true }` and pass its `cds` output as `cds.shared_resources`

## Usage

1. Update the values in `terraform.tfvars`:  

    ```hcl
    entra_id          = "0b659685-1a00-43cd-b994-555bac390ecf"
    entra_tenant_name = "Test Entra"
    subscription_id   = "123456789012"
    subscription_name = "1b3af1a2-f15e-4ea8-8814-1adb073a8cde"
    ```

2. To enable SCA or Cloud Discovery, use the Commons module in your root configuration and pass its output:

    ```hcl
    module "cce_azure_shared" {
      source   = "path/to/terraform-azure-cce-commons"
      entra_id = var.entra_id
      sca      = { enable = true, parameters = { sca_entra_onboarding = true, ... } }
      cds      = { enable = true }
    }

    module "cce_azure_subscription" {
      source              = "path/to/terraform-azure-cce-subscription"
      entra_id            = var.entra_id
      entra_tenant_name   = var.entra_tenant_name
      subscription_id     = var.subscription_id
      subscription_name   = var.subscription_name
      sia                 = { enable = true }
      sca = {
        enable           = true
        shared_resources = module.cce_azure_shared.sca
      }
      cds = {
        enable           = true
        shared_resources = module.cce_azure_shared.cds
      }
    }
    ```

    For the full Cloud Discovery steps, including offboarding, see the `examples/cloud_discovery_onboarding` example in `terraform-azure-cce-commons`.

3. Initialize Terraform:  

    ```bash
    terraform init
    ```

4. Review the plan:  

    ```bash
    terraform plan
    ```

5. Apply the configuration:  

    ```bash
    terraform apply
    ```

## What Gets Created

### In Azure 

**SIA (Secure Infrastructure Access) Application:**
* Azure AD Application: `CyberArk-dpa`
* Service principal for SIA
* Custom role definition: `CyberArk-SIA-Role-{subscription_id}-{uuid}` with permissions for:
  - VM discovery and management
  - Network interfaces and public IPs
  - Resource graph queries
  - Subscription resource group access
* Federated Identity Credential for workload identity federation  

**When SCA is enabled** (with `sca.enable = true` and `sca.shared_resources` from Commons):
* Role assignment of the SCA resource app (from Commons) to the SCA resource custom role at this subscription scope
* SCA service registration in CCE for the subscription

**When Cloud Discovery is enabled** (with `cds.enable = true` and `cds.shared_resources` from Commons):
* Cloud Discovery access for the subscription, using the shared resources from Commons
* Cloud Discovery service registration in CCE for the subscription

### In Idira

* Subscription registration in CCE  
* SIA (Secure Infrastructure Access) enabled for VM discovery and privileged access  
* SCA service resources for the subscription
* Cloud Discovery service resources for the subscription

## Outputs

This example outputs:

* `sia_app_id`: The SIA app registration (client) ID (when SIA enabled)

When SCA or Cloud Discovery is enabled, their app IDs and WIF user IDs come from the Commons module output; this example does not expose separate SCA or Cloud Discovery outputs.

## Next Steps

After successful deployment:

1. Verify the subscription appears in CCE. 
2. Verify SIA (Secure Infrastructure Access) is active and can discover VMs.
