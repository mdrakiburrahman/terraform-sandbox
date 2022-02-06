#######################################################
# Create new HashiCups user for TF Provider
#######################################################
# Create new user
curl -X POST docker_compose_api_1:9090/signup -d '{"username":"education", "password":"test123"}'

# Sign in and set env variable
HASHICUPS_TOKEN=$(curl -X POST docker_compose_api_1:9090/signin -d '{"username":"education", "password":"test123"}' | jq .token | sed 's/\"//g')

########################################################
# Play with orders
########################################################
# Create order
curl -X POST -H "Authorization: ${HASHICUPS_TOKEN}" docker_compose_api_1:9090/orders -d '[{"coffee": { "id":1 }, "quantity":4}, {"coffee": { "id":3 }, "quantity":3}]'
# {
#    "id":1,
#    "items":[
#       {
#          "coffee":{
#             "id":1,
#             "name":"Packer Spiced Latte",
#             "teaser":"Packed with goodness to spice up your images",
#             "description":"",
#             "price":350,
#             "image":"/packer.png",
#             "ingredients":null
#          },
#          "quantity":4
#       },
#       {
#          "coffee":{
#             "id":3,
#             "name":"Nomadicano",
#             "teaser":"Drink one today and you will want to schedule another",
#             "description":"",
#             "price":150,
#             "image":"/nomad.png",
#             "ingredients":null
#          },
#          "quantity":3
#       }
#    ]
# }

# Get
curl -X GET -H "Authorization: ${HASHICUPS_TOKEN}" docker_compose_api_1:9090/orders/1

########################################################
# Test the provider
########################################################
# Clone branch that has completed code because of weird JSON error
git clone --branch implement-complex-read https://github.com/hashicorp/terraform-provider-hashicups
cd terraform-provider-hashicups

########################################################
# ⚠ CLEAN UP REPO ⚠
########################################################
# 1. Replace localhost:19090 with docker_compose_api_1:9090 in 
#    a. hashicups/data_source_coffee.go, line 73
#    b. terraform-provider-hashicups/vendor/github.com/hashicorp-demoapp/   hashicups-client-go/client.go, line 13
#    c. terraform-provider-hashicups/vendor/github.com/hashicorp-demoapp/hashicups-client-go/client.go, line 11

# 2. Delete terraform-provider-hashicups/vendor directory
# 3. Delete go.mod and go.sum files
# 4. Main.tf - remove creds since we will use ENV
########################################################
# Create empty go.mod file because the one from the repo is trash
go mod init terraform-provider-hashicups

# Create vendor directory for downloading dependencies
go mod vendor

# Variables for build
TF_VENDOR_VERSION='0.2' # Random
OS_ARCH="$(go env GOHOSTOS)_$(go env GOHOSTARCH)" # Generate OS_ARCH dynamically

# Create a plugins directory for the TF provider
mkdir -p ~/.terraform.d/plugins/hashicorp.com/edu/hashicups/$TF_VENDOR_VERSION/$OS_ARCH

# Build binary in root of repo as terraform-provider-hashicups
go build -o terraform-provider-hashicups

# Move binary
mv terraform-provider-hashicups ~/.terraform.d/plugins/hashicorp.com/edu/hashicups/$TF_VENDOR_VERSION/$OS_ARCH

# Change to examples directory
cd examples

# Now, instead of updating provider block, we leverage the environment variables to authenticate
export HASHICUPS_USERNAME=education
export HASHICUPS_PASSWORD=test123

# Ensure to replace provider creds in main.tf

# Debug enabled
export TF_LOG=TRACE

# Initialize
terraform init

# Plan
terraform plan

# Apply
terraform apply --auto-approve