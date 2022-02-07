#######################################################
# Sample Orders Create request
#######################################################
# curl -X POST -H "Authorization: ${HASHICUPS_TOKEN}" localhost:19090/orders -d '[{"coffee": { "id":1 }, "quantity":4}, {"coffee": { "id":3 }, "quantity":3}]'

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

# Init, plan and apply
terraform init
terraform plan
terraform apply --auto-approve