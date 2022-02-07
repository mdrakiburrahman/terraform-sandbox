#######################################################
# Setup
#######################################################
# Create new user
curl -X POST docker_compose_api_1:9090/signup -d '{"username":"education", "password":"test123"}'

#######################################################
# Test provider
#######################################################
# Updated the build file with linux_amd64
make install

# Change to examples directory
cd examples

# Set env variables for auth
export HASHICUPS_USERNAME=education
export HASHICUPS_PASSWORD=test123

# Debug enabled
export TF_LOG=TRACE

# Init, plan and apply
terraform init && terraform plan
terraform apply --auto-approve

#######################################################
# Validate
#######################################################
HASHICUPS_TOKEN=$(curl -X POST docker_compose_api_1:9090/signin -d '{"username":"education", "password":"test123"}' | jq .token | sed 's/\"//g')
curl -X GET -H "Authorization: ${HASHICUPS_TOKEN}" docker_compose_api_1:9090/orders/1