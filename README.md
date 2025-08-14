# Azure Application Gateway with Terraform

Demo repo using Terraform to deploy an [Azure Application Gateway](https://learn.microsoft.com/en-us/azure/application-gateway/overview?WT.mc_id=DOP-MVP-5001655) resource

## Developer/environment configuration

In HCP Terraform:

1. **New** | **Workspace**
2. Select project
3. Click **Create**
4. Select CLI-driven workflow
5. Enter workspace name 'terraform-appgw'

<https://www.hashicorp.com/en/blog/access-azure-from-hcp-terraform-with-oidc-federation>

<https://developer.hashicorp.com/terraform/cloud-docs/workspaces/dynamic-provider-credentials/azure-configuration>

## Azure

1. Create Azure resource group

    ```bash
    az group create --name rg-terraform-appgw-australiaeast --location australiaeast
    ```

2. Create service principal and role assignments

    ```bash
    az ad sp create-for-rbac --name sp-terraform-appgw-australiaeast --role Contributor --scopes /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-terraform-appgw-australiaeast
    ```

    Make a note of the appID and tenant ID. Use the appId in the next command:

    ```bash
    az role assignment create --assignee appId --role "Role Based Access Control Administrator" --scope /subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-terraform-appgw-australiaeast
    ```

3. Create `credential.json`

    ```json
    {
        "name": "tfc-plan-credential",
        "issuer": "https://app.terraform.io",
        "subject": "organization:flcdrg:project:my-project-name:workspace:terraform-appgw:run_phase:plan",
        "description": "Terraform Plan",
        "audiences": [
            "api://AzureADTokenExchange"
        ]
    }
    ```

4. And create federated credentials for your service principal. The `--id` parameter should be set to the appId that you noted previously.

    ```bash
    az ad app federated-credential create --id xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx --parameters credential.json
    ```

    Update the `credential.json` file and replace 'plan' with 'apply' (3 places). Create a second federated credential by running the above command again.

5. Repeat this process to enable authentication from GitHub Actions (for the deployment to the storage accounts). Replace `octo-org` with your username or organisation, and `octo-repo` with the GitHub repository name.

    ```json
    {
        "name": "main",
        "issuer": "https://token.actions.githubusercontent.com",
        "subject": "repo:octo-org/octo-repo:environment:production",
        "description": "Production environment",
        "audiences": [
            "api://AzureADTokenExchange"
        ]
    }
    ```

6. Get the Azure subscription ID:

    ```bash
    az account subscription list
    ```

7. Back in HCP Terraform, set the following environment variables in your workspace

    - `TFC_AZURE_PROVIDER_AUTH` = true
    - `TFC_AZURE_RUN_CLIENT_ID` = \<appId value\>
    - `ARM_SUBSCRIPTION_ID` = Azure subscription id
    - `ARM_TENANT_ID` = Azure tenant id

8. Click on your profile and select **Account settings**, then **Tokens**.
9. Click on **Create an API token**
10. In **Description** field enter `terraform-appgw-australiaeast`
11. Review (and adjust if required) the expiration date
12. Click **Create**
13. Note the token value.

## GitHub Actions secrets

To allow the GitHub Action workflows to connect to HCP Terraform and to Azure, in the GitHub project

1. Go to **Settings**, **Secrets and Variables**
2. In **Actions**, click on **New repository secret**
3. In **Name**, enter `TF_API_TOKEN`
4. In **Secret**, paste the HCP Terraform token, and click **Add secret**
5. Also add the same variable as a **Dependabot secret** (so that Dependabot pull requests can succeed)
6. Repeat this process for the following variables. They only need to be added as Repository Secrets:

    - `AZURE_CLIENT_ID` the Application (client) ID
    - `AZURE_TENANT_ID` the Directory (tenant) ID
    - `AZURE_SUBSCRIPTION_ID` your subscription ID
