# Example: Basic CCE Subscription Onboarding with SIA and SCA

This example demonstrates the minimal configuration required to onboard an Azure subscription to Connect Cloud Environments (CCE) with SIA (Secure Infrastructure Access) enabled. Optionally, SCA (Secure Cloud Access) can be enabled by passing `shared_resources` from the Commons module.

## What This Example Does

* Onboards your Azure subscription to CCE  
* Enables SIA (Secure Infrastructure Access) for VM discovery and privileged access management  
* Optionally enables SCA at subscription scope (when `sca.shared_resources` from Commons is provided)

## Prerequisites

* Azure subscription and Microsoft Entra tenant credentials  
* CyberArk tenant with CCE  
* Terraform >= 1.8.5  
* CyberArk `idsec` provider configured - https://registry.terraform.io/providers/cyberark/idsec/latest/docs#example-usage  
* For SCA: run the Commons module first and pass its `sca` output as `shared_resources`

## Usage

1. Update the values in `terraform.tfvars`:  

    ```hcl
    entra_id          = "0b659685-1a00-43cd-b994-555bac390ecf"
    entra_tenant_name = "Test Entra"
    subscription_id   = "123456789012"
    subscription_name = "1b3af1a2-f15e-4ea8-8814-1adb073a8cde"
    ```

2. To enable SCA, use the Commons module in your root configuration and pass its output:

    ```hcl
    module "cce_azure_shared" {
      source   = "path/to/terraform-azure-cce-commons"
      entra_id = var.entra_id
      sca      = { enable = true, parameters = { sca_entra_onboarding = true, ... } }
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
    }
    ```

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

### In CyberArk

* Subscription registration in CCE  
* SIA (Secure Infrastructure Access) enabled for VM discovery and privileged access  
* SCA service resources for the subscription

## Outputs

This example outputs:

* `sia_app_id`: The SIA app registration (client) ID (when SIA enabled)

When SCA is enabled, SCA app IDs and WIF user IDs come from the Commons module output; this example does not expose separate SCA outputs.

## Next Steps

After successful deployment:

1. Verify the subscription appears in your CCE console  
2. Verify SIA (Secure Infrastructure Access) is active and can discover VMs  
