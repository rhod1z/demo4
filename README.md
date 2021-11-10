## An Azure DevOps and Azure App Service demo pipeline.

### Summary
This repo demonstrates a deployment pipeline using azure-pipelines.yaml, deploying to Azure App Service.

The core application components are:

- A 'MyHealth' web app
- An Azure SQL database

In addition it demonstrates the use of several other technologies and concepts:

- Git and git branching strategy ( prd | dev | stg )
- Docker application build with an Azure Container Registry repo
- Terraform provision of 'prd/stg' and 'dev' environments based on branch name
- Authorisation gate to control and review terraform code changes
- Custom domains and SSL binding
- Autoscaling
- Azure SQL failover group for high availability
- Canary deployment can be easily facilitated using % traffic allocation
- Blue/Green deployment can be easily facilitated utilising staging slots with emergency rollback available using swaps

### Pipeline Overview
![Pipeline Overview](https://raw.githubusercontent.com/rhod3rz/demo2-AzureDevOps-WebApp/prd/screenshots/pipeline-overview.png "Pipeline Overview")

### Pipeline
![Pipeline](https://raw.githubusercontent.com/rhod3rz/demo2-AzureDevOps-WebApp/prd/screenshots/pipeline.png "Pipeline")

### Branching Strategy
![Branching Strategy](https://raw.githubusercontent.com/rhod3rz/demo2-AzureDevOps-WebApp/prd/screenshots/branching-strategy.png "Branching Strategy")

### Pre-Requisites
The pipeline relies on the following components:

- Azure DevOps Service Connection - Azure  
An ADO service connection using a 'service principal' to azure called 'payg2106'; see terraform\_backends\azure\12-link-to-azure-devops.sh  
Azure-pipelines.yml refers to this as [azSubscription: 'payg2106']

- Azure DevOps Service Connection - Azure Container Registry (aka Docker Registry)  
An ADO service connection to docker / azure container registry called 'acrdlnteudemoapps210713'; see terraform\_backends\azure\12-link-to-azure-devops.sh  
Azure-pipelines.yml refers to this as [containerRegistry: 'acrdlnteudemoapps210713']

- Azure DevOps Variable Group (Linked to KeyVault)  
An ADO variable group linked to azure key vault called 'kv-core-210713', and containing ARM-ACCESS-KEY, KV-ARM-CLIENT-ID, ARM-CLIENT-SECRET, KV-ARM-SUBSCRIPTION-ID, KV-ARM-TENANT-ID, KV-SQL-ADMIN-PASSWORD and KV-SQL-ADMIN-USERNAME; see terraform\_backends\azure\12-link-to-azure-devops.sh  
Azure-pipelines.yml refers to this as [variableGroupKV: 'kv-core-210713']

### Workflow

---
#### 1. Build the 'prd' Branch.
---
Instructions:

a. Update line 85 in src\src\MyHealth.Web\Views\Home\Index.cshtml with a new timestamp.  
`<span class="banner-footer-text-right">& BE HEALTHY - 211019-1942</span>`  
b. Push the 'prd' branch to github using the version number as a commit message.  
`git add .`  
`git commit -m "211019-1942"`  
`git push -u origin prd`  
c. In ADO create a project, then pipelines > new pipeline > github/yaml > select the correct repo then run. This will start the pipeline building.  
d. Manually review the plan at the 'Wait for Validation' stage, and if happy authorise to proceed.  

Pipeline Actions:

- Evaluate the branch name and Terraform provision the 'prd' environment (inc. manual approval gate)
- Compile the code, create docker images and push to ACR
- Evaluate the branch name and deploy the app to Azure App Service (prd environment)

Output:

You now have a single 'prd' branch deployed. Test using the following url https://prd.rhod3rz.com/.  
When running the app, notice the version number is as you set in step 1a.  
The completed pipeline will look like the pipeline image above.

---
#### 2. Build the 'dev' Branch.
---
Instructions:

It's time to simulate a change ...

a. Create a new branch 'dev', and switch to it e.g.  
`git checkout -b dev`  
b. Update line 85 in src\src\MyHealth.Web\Views\Home\Index.cshtml with a new timestamp.  
`<span class="banner-footer-text-right">& BE HEALTHY - 211020-1052</span>`  
c. Push the 'dev' branch to github using the version number as a commit message.  
`git add .`  
`git commit -m "211020-1052"`  
`git push -u origin dev`  
d. This will automatically trigger a pipeline build as we have 'trigger:*' set in azure-pipelines.yml. Manually review the plan at the 'Wait for Validation' stage, and if happy authorise to proceed.  

Pipeline Actions:

- Evaluate the branch name and Terraform provision the 'dev' environment (inc. manual approval gate)
- Compile the code, create docker images and push to ACR
- Evaluate the branch name and deploy the app to Azure App Service (dev environment)

Output:

You now have two branches, 'prd' and 'dev'. To simplify the dev environment a custom domain name and ssl binding isn't used for 'dev'.  
Test via the azurewebsites.net url. e.g. https://dev-app-myhealth-211019-1100.azurewebsites.net/.  
When running the app, notice the version number in the 'dev' environment is now the updated one you set in step 2b.

---
#### 3. Merge the 'dev' Branch to 'stg' Branch.
---
Instructions:

It's time to merge the 'dev' changes into the 'stg' branch ...

a. Create a new branch 'stg', and switch to it. This is now a copy of 'dev' e.g.  
`git checkout -b stg`  
b. Commit changes e.g.  
`git push -u origin stg`  
c. This will automatically trigger a pipeline build as we have 'trigger:*' set in azure-pipelines.yml. Manually review the plan at the 'Wait for Validation' stage, and if happy authorise to proceed.

Pipeline Actions:

- Evaluate the branch name and Terraform provision the 'stg' environment (inc. manual approval gate); stg is just a slot on prd which has already been created so there is nothing to create here.
- Compile the code, create docker images and push to ACR
- Evaluate the branch name and deploy the app to Azure App Service (stg environment)

Output:

You now have three branches, 'prd', 'dev' and 'stg'. Test using the following url https://stg.rhod3rz.com/.  
When running the app, notice the version number in the 'stg' environment is now the updated one carried over from 'dev'.

---
#### 4. Merge the 'stg' Branch to 'prd' Branch.
---
Instructions:

Assuming there were no issues with the 'stg' deployment it's time to merge those changes into 'prd' ...

a. Create a 'Pull Request' to merge 'stg' into 'prd' and delete the 'stg' branch from GitHub.  
b. Delete the 'dev' branch from GitHub.  
c. Delete the 'dev' and 'stg' branch from local Git e.g.  
`git checkout prd`  
`git branch -d dev`  
`git branch -d stg`  
`git remote prune origin`  
`git pull origin prd`  

Pipeline Actions:

- Evaluate the branch name and Terraform provision the 'prd' environment (inc. manual approval gate); note there is nothing to deploy at this stage as the infrastructure is built and nothing has changed.
- Compile the code, create docker images and push to ACR
- Evaluate the branch name and deploy the app to Azure App Service (prd environment)

Output:

You're now back to a single branch, 'prd'. Test as before e.g. https://prd.rhod3rz.com/.  
When running the app, notice the version number in the 'prd' environment is now the updated one you pushed through 'dev' and 'stg'.

---
#### 5. Emergency Rollback.
---
Instructions:

Aargh something has gone wrong and been missed in testing! You need to rollback to the previous version asap ...

Before pushing new code to 'prd' the pipeline swapped the prd and stg slots. This enables a quick rollback to the last known good configuration.

To roll back it's a simple step of swapping the 'prd' and 'stg' slots via the portal 🦸‍♂️😀
