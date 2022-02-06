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
# Create
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

# Cleanup
go mod tidy

# Replace localhost in data_source_coffee.go, line 73

# Folder for vendor dependencies - reads from go.mod
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

# Replace provider creds in main.tf

# Initialize
terraform init

# Plan
terraform plan

# Apply
terraform apply --auto-approve