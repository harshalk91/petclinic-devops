
Edit terraform.tfvars and make necessary changes as per your environment.

# Create VPC:
terraform init \
terraform plan -target=module.create_vpc -out=vpc.out \
terraform apply vpc.out

============================================
# Creating Jenkins instance
terraform plan -target=module.create-jenkins-instance -out=create-jenkins-instance.out \
terraform apply create-jenkins-instance.out

============================================
# Create app instance
terraform plan -target=module.create-app-instance -out=create-app-instance.out \
terraform apply create-app-instance.out
