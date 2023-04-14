# Provision the infrasturctures

`Dependencies`

1. Have terraform running on your workstation 
2. Already setup authentication from workstation to GCP 
3. Have a file called `credentials.json` to be used to authenticate with GCP
4. Create private and public key which will be used for logging in the workstation. 


There is a `cloud-storage` folder which contains the terraform codes for creating the cloud-storage to keep the terraform state files.

The state files are kept in the google cloud storage


## Instructions for running the application 

1. Firstly run terraform init, terraform plan on the `cloud-storage` folder to keep the statefile. 
2. Once terraform apply finished running from `cloud-storage` it will create cloud storage. 
3. Put the details of the s3 bucket in `sql\versions.tf` line 3


2. Replace values.tfvars files with the correspoinding correct values. 
3. cd into sql folder and run terraform init, terraform plan -var-file=values.tfvars, terraform apply -var-file=values.tfvars