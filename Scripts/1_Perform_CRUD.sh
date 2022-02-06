########################################################
# Hashicups spinup
########################################################

# Spin up 2 containers in powershell, in this same network, because the container mounts filesystems
docker network inspect tf-network | grep docker_compose
# > "Name": "docker_compose_db_1",
# > "Name": "docker_compose_api_1",

# Healthcheck from within the docker network reaches port over local, NOT 19090
curl docker_compose_api_1:9090/health

########################################################
# Build Terraform Provider and move it to .terraform.d
########################################################
# Clone repo
git clone https://github.com/hashicorp/terraform-provider-hashicups
cd terraform-provider-hashicups

# Folder for vendor dependencies - reads from go.mod
go mod vendor
# Go downloads everything into: C:\Users\mdrrahman\Documents\GitHub\terraform-sandbox\terraform-provider-hashicups\vendor

# From: https://github.com/hashicorp/terraform-provider-hashicups/releases/tag/v0.3.3
TF_VENDOR_VERSION='0.3.3'
# Set OS_ARCH
# terraform -v
# > Terraform v1.1.5
# > on linux_amd64
OS_ARCH="$(go env GOHOSTOS)_$(go env GOHOSTARCH)" # Generate OS_ARCH dynamically

# Create a plugins directory for the TF provider
mkdir -p ~/.terraform.d/plugins/hashicorp.com/edu/hashicups/$TF_VENDOR_VERSION/$OS_ARCH

# Build binary in root of repo as terraform-provider-hashicups
go build -o terraform-provider-hashicups

# Move binary
mv terraform-provider-hashicups ~/.terraform.d/plugins/hashicorp.com/edu/hashicups/$TF_VENDOR_VERSION/$OS_ARCH

#######################################################
# Create new HashiCups user for TF Provider
#######################################################
# Create new user
curl -X POST docker_compose_api_1:9090/signup -d '{"username":"education", "password":"test123"}'
# {"UserID":1,"Username":"education","token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NDQyNTQ1MTQsInVzZXJfaWQiOjEsInVzZXJuYW1lIjoiZWR1Y2F0aW9uIn0.RZcbV8V7yaYdwwnNKUVg6ht_DrwohYflW14go78ePUw"}

# Sign in and set env variable
HASHICUPS_TOKEN=$(curl -X POST docker_compose_api_1:9090/signin -d '{"username":"education", "password":"test123"}' | jq .token | sed 's/\"//g')

#######################################################
# Initialize Terraform
#######################################################
cd ../1_Perform_CRUD

# Initialize
terraform init
# So basically, this initializes the hashicups terraform provider, which uses the client-go SDK to talk to the HashiCups API

# Note that main.tf must have to authenticate with the HashiCups API:
# provider "hashicups" {
#   username = "education"
#   password = "test123"
#   host = "http://docker_compose_api_1:9090"
# }

# Plan
terraform plan

# Apply
terraform apply --auto-approve

# In the docker container, we see:
# 2022-02-06T17:56:08.562Z [INFO] Handle User | signin
# 2022-02-06T17:56:08.569Z [INFO] Handle Orders | CreateOrder
# 2022-02-06T17:56:08.578Z [INFO] Handle Orders | GetUserOrder

# View state
terraform state show hashicups_order.edu

# Verify order via curl
curl -X GET -H "Authorization: ${HASHICUPS_TOKEN}" docker_compose_api_1:9090/orders/1

# Made a change, now reapply
terraform apply --auto-approve
# In API:
# 2022-02-06T18:08:31.839Z [INFO] Handle User | signin
# 2022-02-06T18:08:31.845Z [INFO] Handle Orders | GetUserOrder
# 2022-02-06T18:08:31.897Z [INFO] Handle User | signin
# 2022-02-06T18:08:31.906Z [INFO] Handle Orders | UpdateOrder
# 2022-02-06T18:08:31.915Z [INFO] Handle Orders | GetUserOrder

#######################################################
# Data block - get ingredients
#######################################################
# Added data and output to main.tf

#######################################################
# Destroy
#######################################################
terraform destroy --auto-approve

# Verify order via curl
curl -X GET -H "Authorization: ${HASHICUPS_TOKEN}" docker_compose_api_1:9090/orders/1

# Values still stay in database, but in "deleted" timestamp - as a design decision

