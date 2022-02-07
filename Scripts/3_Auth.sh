#######################################################
# Create new HashiCups user for TF Provider
#######################################################
# Create new user
curl -X POST docker_compose_api_1:9090/signup -d '{"username":"education", "password":"test123"}'
# {"UserID":1,"Username":"education","token":"eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE2NDQyNTQ1MTQsInVzZXJfaWQiOjEsInVzZXJuYW1lIjoiZWR1Y2F0aW9uIn0.RZcbV8V7yaYdwwnNKUVg6ht_DrwohYflW14go78ePUw"}

# Sign in and set env variable
HASHICUPS_TOKEN=$(curl -X POST docker_compose_api_1:9090/signin -d '{"username":"education", "password":"test123"}' | jq .token | sed 's/\"//g')

# Download client library
go mod vendor

#######################################################
# Test provider
#######################################################
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

# Initialize
terraform init

# Plan
terraform plan

# Apply
terraform apply --auto-approve

#######################################################
# Redo
#######################################################
# To pull the repo, use:
git clone --branch auth-configuration https://github.com/hashicorp/terraform-provider-hashicups