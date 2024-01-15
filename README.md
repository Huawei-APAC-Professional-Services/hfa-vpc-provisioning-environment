# hfa-vpc-provisioning-environment
This Terraform configuration aims at provisioning Terraform execution environment within a VPC and use PostgreSQL as the backend to provide state-lock capability

## Introduction 
It's reasonable for migrating the Terraform state for this configuration to the backend that wil be created by this configuration after the successful execution of this configuration. 

This configuration uses local backend by default for simplicity, it can be changed to whatever backends available for your environment.

## Getting Started

### Create Artifact Repo
1. Go to `CodeArts` console and Choose `Artifact` service in your project
![CreateArtifactRepo](./image/001_CreateArtifact_Repo.png)

2. Choose the default repo for your project
![CreateArtifactRepo01](./image/001_CreateArtifact_Repo_01.png)

3. Create a folder under the repo for stroring Terraform state
![CreateArtifactRepo02](./image/001_CreateArtifact_Repo_02.png)

4. Upload the empty `terraform.tfstate` file in this repo to the Artifact repo, the purpose of this is to keep CodeArts build job going when it's first executed
![CreateArtifactRepo03](./image/001_CreateArtifact_Repo_03.png)

### Clone Code Repository to CodeArts
1. On the left side pannel of CodeArts console, Choose `Code` --> `Repo`
![CreateCodeRepo](.//image/001_CreateCode_Repo_01.png) 

2. On the `Repo` console, Choose `+ New Repository` menu and Click `Import Repository` to import a repository from Github
![CreateCodeRepo](./image/001_CreateCode_Repo_02.png)

3. On the Code Repo Creation page, provide `https://github.com/Huawei-APAC-Professional-Services/hfa-vpc-provisioning-environment.git` as source and check `Username and password not required` option
![CreateCodeRepo](./image/001_CreateCode_Repo_03.png) 

4. On the next page, only change `Repo Sync Settings` to `All branches` and leave other parameters to default
![CreateCodeRepo](./image/001_CreateCode_Repo_04.png)

### Create Credentials for creating CodeArts agent
1. Log in to Huawei Cloud Console, Click username on the top right corner of the console and Select `My Credentials`
![CreateCredentials](./image/003_CreateCredential_01.png)

2. 
### Create CodeArts Build Job
1. On the left side pannel of CodeArts console, Choose `CICD` --> `Build`
![CreateBuildJob](./image/002_CreateBuildJob_01.png)

2. On the `CodeArts Build` Console, Click `+ Create Task` button
![CreateBuildJob02](./image/002_CreateBuildJob_02.png)

3.  On the `Create Build Task` page, select the imported repo as the `Code Source`
![CreaateBuildJob03](./image/002_CreateBuildJob_03.png)

4. Choose `Blank Template` as the `Build Template`
![CreateBuildJob04](./image/002_CreateBuildJob_04.png) 

5. 
### Create CodeArts Pipeline