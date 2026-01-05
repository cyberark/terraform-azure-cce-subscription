# Example 1: Basic CCE Subscription Onboarding

This example demonstrates the minimal configuration required to onboard an Azure Subscription to CyberArk CCE (Connect Cloud Environments) with at least one service enabled.

## What This Example Does

* Onboards your Azure Subscription to CyberArk CCE  
* Enables Dummy - an example service  

## Prerequisites

* Azure Subscription and entra credentials  
* CyberArk tenant with CCE  
* Terraform >= 1.8.5  
* CyberArk `idsec` provider configured - https://registry.terraform.io/providers/cyberark/idsec/latest/docs#example-usage  

## Usage

1. Update the values in `terraform.tfvars`:  

    ```hcl
    entra_id          = "0b659685-1a00-43cd-b994-555bac390ecf"
    entra_tenant_name = "Test Entra"
    subscription_id   = "123456789012"
    subscription_name = "1b3af1a2-f15e-4ea8-8814-1adb073a8cde"
    ```

2. Initialize Terraform:  

    ```bash
    terraform init
    ```

3. Review the plan:  

    ```bash
    terraform plan
    ```

4. Apply the configuration:  

    ```bash
    terraform apply
    ```

## What Gets Created

### In Azure 

* Azure AD Application: `CyberArk-Dummy-app`  
* Service Principal for the Dummy application  
* Microsoft Graph API Permissions with admin consent:  
  * `AuditLog.Read.All` - Allows reading audit log data  
  * `Directory.Read.All` - Allows reading directory data  
* Federated Identity Credential for workload identity federation  

### In CyberArk

* Subscription registration in CCE  
* Dummy service enabled  

## Outputs

This example outputs:

* `dummy_app_id`: The Application (client) ID of the CyberArk Dummy app  

## Next Steps

After successful deployment:

1. Verify the subscription appears in your CyberArk CCE console  
2. Verify Dummy service is active  
3. To enable additional services, see [full\_services](../full_services/)  
