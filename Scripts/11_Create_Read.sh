#######################################################
# Clone Plugin Framework flavor of Hashicups
#######################################################
# Boilerplate, not main! We're going to build up to main
git clone --branch boilerplate https://github.com/hashicorp/terraform-provider-hashicups-pf
cd terraform-provider-hashicups-pf

#######################################################
# Setup
#######################################################
# Create new user
curl -X POST docker_compose_api_1:9090/signup -d '{"username":"education", "password":"test123"}'
HASHICUPS_TOKEN=$(curl -X POST docker_compose_api_1:9090/signin -d '{"username":"education", "password":"test123"}' | jq .token | sed 's/\"//g')
cd ..

# Set env variables for auth
export HASHICUPS_USERNAME=education
export HASHICUPS_PASSWORD=test123

#######################################################
# Get Order Schema sample JSON
#######################################################
curl -X POST -H "Authorization: ${HASHICUPS_TOKEN}" docker_compose_api_1:9090/orders -d '[{"coffee": { "id":1 }, "quantity":4}, {"coffee": { "id":3 }, "quantity":3}]' | jq .

# {
#   "id": 1,
#   "items": [
#     {
#       "coffee": {
#         "id": 1,
#         "name": "Packer Spiced Latte",
#         "teaser": "Packed with goodness to spice up your images",
#         "description": "",
#         "price": 350,
#         "image": "/packer.png",
#         "ingredients": null
#       },
#       "quantity": 4
#     },
#     {
#       "coffee": {
#         "id": 3,
#         "name": "Nomadicano",
#         "teaser": "Drink one today and you will want to schedule another",
#         "description": "",
#         "price": 150,
#         "image": "/nomad.png",
#         "ingredients": null
#       },
#       "quantity": 3
#     }
#   ]
# }

# Format code from hashicups directory
go fmt ./...

#######################################################
# Fork repo because this one is bad
#######################################################
git clone --branch create-read-order https://github.com/hashicorp/terraform-provider-hashicups-pf
cd terraform-provider-hashicups-pf

#######################################################
# Build provider locally for testing
#######################################################
# Create terraform RC in root of repo
cat > .terraformrc <<EOF
provider_installation {

  dev_overrides {
      "hashicorp.com/edu/hashicups-pf" = "/root/go/bin"
  }

  # For all other providers, install them directly from their origin provider
  # registries as normal. If you omit this, Terraform will _only_ use
  # the dev_overrides block, and so no other providers will be available.
  direct {}
}
EOF

# Variables for build
TF_VENDOR_VERSION='0.2' # Random
OS_ARCH="$(go env GOHOSTOS)_$(go env GOHOSTARCH)" # Generate OS_ARCH dynamically

# Create a plugins directory for the TF provider
mkdir -p ~/.terraform.d/plugins/hashicorp.com/edu/hashicups-pf/$TF_VENDOR_VERSION/$OS_ARCH

# Build binary in root of repo as terraform-provider-hashicups
go build -o terraform-provider-hashicups-pf

# Move binary
mv terraform-provider-hashicups-pf ~/.terraform.d/plugins/hashicorp.com/edu/hashicups-pf/$TF_VENDOR_VERSION/$OS_ARCH

#######################################################
# Apply Terraform
#######################################################
cd examples

# Debug enabled
export TF_LOG=TRACE

terraform init && terraform plan
terraform apply --auto-approve
# Show state post apply
terraform state show hashicups_order.edu