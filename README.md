# CyberArk CCE Azure Subscription Onboarding with Terraform

## Overview  
This Terraform module automates the onboarding of Azure subscriptions to **CyberArk CCE (Connect Cloud Environments)** with support for multiple service integrations. It uses **Workload Identity Federation (WIF)** for secure, keyless authentication between CyberArk and Azure resources.

The module creates the necessary Azure AD applications, service principals, federated identity credentials, and role assignments, then registers them with CyberArk CCE.

## Features   
- **Automated Azure Subscription Onboarding** to CyberArk CCE  
- **Workload Identity Federation (WIF)** support for secure, passwordless authentication  
- **Modular Service Architecture** with optional service enablement:  
  - `service`: Creates Azure AD app with Microsoft Graph API permissions (AuditLog.Read.All, Directory.Read.All)  
- **Flexible Configuration** - Enable or disable services as needed  
- **Zero Secrets Management** - Uses federated credentials instead of client secrets  
- **Automatic Federated Identity Credential Setup** for each enabled service  
- **Azure Role Assignments** with support for subscription scope

## Prerequisites  
Before using this module, ensure you have:

### Required Tools
- **Terraform** >= 1.8.5  
- **Azure CLI** (authenticated with appropriate permissions)  
- **CyberArk Identity Security tenant** with CCE enabled  

### Required Permissions
- **Azure AD Permissions:**  
  - Application Administrator or Global Administrator role  
  - Ability to create and manage applications and service principals  
  - Ability to grant admin consent for Microsoft Graph API permissions  
- **Azure Permissions:**  
  - Owner or User Access Administrator role on target subscription
  - Ability to create role assignments  

### CyberArk Setup
- CyberArk tenant with CCE configured  
- CyberArk `idsec` provider credentials  
- See [CyberArk idsec Provider Documentation](https://registry.terraform.io/providers/cyberark/idsec/latest/docs)  

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
      version = "~> 0.1"
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
  # Configure via environment variables or explicit config
  # See: https://registry.terraform.io/providers/cyberark/idsec/latest/docs
}

module "cce_azure_subscription" {
  source            = "path/to/module"
  entra_id          = "0b659685-1a00-43cd-b994-555bac390ecf"
  entra_tenant_name = "My Azure Tenant"
  subscription_id   = "34ea05f7-b5bb-40cd-944e-0f8ba82dc4d9"
  subscription_name = "Production Subscription"
  
  # Enable services as needed
  service = {
    enable = true
  }
}
```

### Input Variables

| Name | Description | Type | Required | Default |
|------|-------------|------|----------|---------|
| `entra_id` | The Azure Entra (Tenant) ID | `string` | Yes | - |
| `entra_tenant_name` | The Azure Entra tenant name | `string` | Yes | - |
| `subscription_id` | The Azure subscription ID to onboard | `string` | Yes | - |
| `subscription_name` | The Azure subscription name | `string` | Yes | - |
| `service.enable` | Enable the Service with Microsoft Graph permissions | `bool` | No | `false` |

### Outputs

| Name | Description |
|------|-------------|
| `service_app_id` | The Application (client) ID of the Service app |

### What Gets Created

#### When `service` is Enabled:
- Azure AD Application: `Service-app`  
- Service Principal for the application  
- Microsoft Graph API permissions with admin consent:  
  - `AuditLog.Read.All` (Application permission)  
  - `Directory.Read.All` (Application permission)  
- Federated Identity Credential using CyberArk WIF parameters  

#### In CyberArk CCE:
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
└── service/        # Microsoft Graph API integration
    ├── main.tf
    ├── variables.tf
    └── outputs.tf
```

Each service module:
1. Creates an Azure AD application  
2. Creates a service principal  
3. Configures required permissions or role assignments  
4. Sets up federated identity credentials using WIF parameters from CyberArk  
5. Returns the application ID for registration with CCE  

### Workload Identity Federation

This module leverages Workload Identity Federation (WIF) to enable secure, passwordless authentication:

1. CyberArk provides WIF parameters via the `idsec_cce_azure_identity_params` data source  
2. Each service module receives its specific WIF parameters (issuer, user ID, audience)  
3. Federated identity credentials are created in Azure AD for each enabled service  
4. CyberArk can authenticate to Azure using these federated credentials without managing secrets  

### Terraform Providers

- **cyberark/idsec** (~> 0.1) - CyberArk Identity Security provider for CCE integration  
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
