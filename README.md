# CCE Azure Subscription Onboarding Module

This Terraform module onboards Azure subscriptions to Connect Cloud Environments (CCE) with CyberArk SaaS services. It uses Workload Identity Federation (WIF) for secure keyless authentication between CCE and Azure resources.
CCE helps customers easily adopt CyberArk services and establish secure trust relationships with their Azure environments.

## Overview  

The module creates the necessary Microsoft Entra ID applications, service principals, federated identity credentials, and role assignments, and then registers them with CCE.

## Features   
- **Automated Azure Subscription Onboarding** to CCE  
- **Workload Identity Federation (WIF)** support for secure, passwordless authentication  
- **Modular Service Architecture** with optional service enablement:  
  - `sia`: SIA (Secure Infrastructure Access) for VM discovery and privileged access management
  - `sca`: SCA (Secure Cloud Access) using shared resources from the Commons module; assigns the SCA resource app to the SCA resource custom role at subscription scope
- **Flexible Configuration** - Enable or disable services as needed  
- **Zero Secrets Management** - Uses federated credentials instead of client secrets  
- **Automatic Federated Identity Credential Setup** for each enabled service  
- **Azure Role Assignments** with support for subscription scope

## Prerequisites

Before using this module, ensure that you have the following information and requirements:

1. **CyberArk Identity Security Platform Account**
   - API credentials (client ID and secret)
   - Tenant URL

2. **Azure Requirements**
   - Application Administrator or Global Administrator role
   - Permissions to create and manage applications and service principals
   - Permissions to grant admin consent for Microsoft Graph API permissions
   - Owner or User Access Administrator role on target subscription
   - Permissions to create role assignments
   - Azure CLI authenticated with appropriate permissions

3. **Terraform Requirements**
   - Terraform >= 1.8.5
   - Microsoft Entra ID Provider
   - Azure RM Provider
   - CyberArk idsec Provider

4. **For SCA (Secure Cloud Access)**
   - Use the Commons module (`terraform-azure-cce-commons`) in your root configuration and pass its `sca` output as `sca.shared_resources` when enabling SCA at subscription scope.

## Usage  

### Basic Example

```hcl
terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    idsec = {
      source  = "cyberark/idsec"
      version = "~> 0.2.1"
    }
  }
  required_version = ">= 1.8.5"
}

provider "azurerm" {
  subscription_id = var.subscription_id
  features {}
}

provider "azuread" {}

provider "idsec" {
  # Configure with your CyberArk tenant credentials
  # See: https://registry.terraform.io/providers/cyberark/idsec/latest/docs
}

module "cce_azure_subscription" {
  source            = "path/to/module"
  entra_id          = "0b659685-1a00-43cd-b994-555bac390ecf"
  entra_tenant_name = "My Azure Tenant"
  subscription_id   = "34ea05f7-b5bb-40cd-944e-0f8ba82dc4d9"
  subscription_name = "Production Subscription"
  
  # Enable services as needed
  sia = {
    enable = true
  }
  # Enable SCA (requires Commons module; pass shared_resources)
  sca = {
    enable           = true
    shared_resources = module.cce_azure_shared.sca  # From terraform-azure-cce-commons
  }
}
```

### Input Variables

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| `entra_id` | The Microsoft Entra tenant ID | `string` | Yes | - |
| `entra_tenant_name` | The Microsoft Entra tenant name | `string` | Yes | - |
| `subscription_id` | The Azure subscription ID to onboard | `string` | Yes | - |
| `subscription_name` | The Azure subscription name | `string` | Yes | - |
| `sia.enable` | Enable SIA (Secure Infrastructure Access) | `bool` | No | `false` |
| `sca.enable` | Enable SCA at subscription scope | `bool` | No | `false` |
| `sca.shared_resources` | SCA shared resources from Commons output (required when sca.enable = true). Must include resource_app_id, resource_custom_role_id, resource_wif_user_id. | `object` | `null` | No |

### Outputs

| Name | Description |
|------|-------------|
| `sia_app_id` | The SIA app registration ID (client) (if enabled) |

### What Gets Created

#### When SIA is Enabled:
- Microsoft Entra ID Application: `CyberArk-dpa`  
- Service principal for the application  
- Custom Azure role definition: `CyberArk-SIA-Role-{subscription_id}-{uuid}` with permissions:
  - `Microsoft.Cache/redis/read`
  - `Microsoft.Compute/virtualMachines/read`
  - `Microsoft.Network/networkInterfaces/read`
  - `Microsoft.Network/privateEndpoints/read`
  - `Microsoft.Network/publicIPAddresses/read`
  - `Microsoft.Network/virtualNetworks/read`
  - `Microsoft.Network/virtualNetworks/subnets/read`
  - `Microsoft.ResourceGraph/resources/read`
  - `Microsoft.Resources/subscriptions/resourceGroups/read`
  - `Microsoft.Resources/tags/read`
  - Federated Identity Credential using CCE WIF parameters  

#### When SCA is Enabled (with `sca.enable = true` and `sca.shared_resources` from Commons):
- Role assignment of the SCA resource app (from Commons) to the SCA resource custom role at this subscription scope
- SCA service registration in CCE for the subscription. The resource app and custom role are created by Commons; this module only performs the role assignment at subscription scope and idsec registration.

#### In CCE:
- Azure subscription registered in CCE  
- Enabled services linked to their respective Azure applications  
- Workload Identity Federation configured for secure access  

## Documentation

### Examples
This repository includes a complete example:

- **[basic](./examples/basic/)** - Minimal configuration with one service enabled  

### Service Modules Architecture

The module uses a modular architecture where each service is implemented as a separate sub-module:

```
services_modules/
└── sia/            # SIA (Secure Infrastructure Access) integration
    ├── main.tf
    ├── variables.tf
    └── outputs.tf
```

Each service module:
1. Creates an Microsoft Entra ID application  
2. Creates a service principal  
3. Configures required permissions or role assignments  
4. Sets up federated identity credentials using WIF parameters from CCE  
5. Returns the application ID for registration with CCE  

### Workload Identity Federation

This module leverages Workload Identity Federation (WIF) to enable secure passwordless authentication:

1. CCE provides WIF parameters via the `idsec_cce_azure_identity_params` data source  
2. Each service module receives its specific WIF parameters (issuer, user ID, audience)  
3. Federated identity credentials are created in Microsoft Entra ID for each enabled service  
4. CCE can authenticate to Azure using these federated credentials without managing secrets  

### Terraform Providers

- **cyberark/idsec** (~> 0.2.1) - CyberArk Identity Security provider for CCE integration  
- **hashicorp/azuread** (~> 3.0) - Azure Active Directory provider  
- **hashicorp/azurerm** (~> 4.0) - Azure Resource Manager provider  

## Licensing  
This repository is subject to the following licenses:  
- **CyberArk Privileged Access Manager**: Licensed under the [CyberArk Software EULA](https://www.cyberark.com/EULA.pdf).  
- **Terraform templates**: Licensed under the Apache License, Version 2.0 ([LICENSE](LICENSE)).  

## Contributing  
We welcome contributions! Please see our [Contributing Guidelines](CONTRIBUTING.md) for more details.

## About  
CyberArk is a global leader in **Identity Security**, providing powerful solutions for managing privileged access. Learn more at [www.cyberark.com](https://www.cyberark.com).  
