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

# Create a new directory for import
mkdir import && cd import

# Set env variables for auth
export HASHICUPS_USERNAME=education
export HASHICUPS_PASSWORD=test123

# Debug enabled
# export TF_LOG=TRACE

#######################################################
# Create order via API
#######################################################
HASHICUPS_TOKEN=$(curl -X POST docker_compose_api_1:9090/signin -d '{"username":"education", "password":"test123"}' | jq .token | sed 's/\"//g')
curl -X POST -H "Authorization: ${HASHICUPS_TOKEN}" docker_compose_api_1:9090/orders -d '[{"coffee": { "id":1 }, "quantity":4}, {"coffee": { "id":3 }, "quantity":69}]'
# {"id":2,"items":[{"coffee":{"id":1,"name":"Packer Spiced Latte","teaser":"Packed with goodness to spice up your images","description":"","price":350,"image":"/packer.png","ingredients":null},"quantity":4},{"coffee":{"id":3,"name":"Nomadicano","teaser":"Drink one today and you will want to schedule another","description":"","price":150,"image":"/nomad.png","ingredients":null},"quantity":69}]}

# Of importance
# "id":2

#######################################################
# Import
#######################################################
# Init
terraform init

# Import via order id
terraform import hashicups_order.sample 2

# hashicups_order.sample: Importing from ID "2"...
# hashicups_order.sample: Import prepared!
#   Prepared hashicups_order for import
# hashicups_order.sample: Refreshing state... [id=2]

# Import successful!

# The resources that were imported are shown above. These resources are now in
# your Terraform state and will henceforth be managed by Terraform.

# View latest state
terraform state show hashicups_order.sample
# # hashicups_order.sample:
# resource "hashicups_order" "sample" {
#     id = "2"

#     items {
#         quantity = 4

#         coffee {
#             id     = 1
#             image  = "/packer.png"
#             name   = "Packer Spiced Latte"
#             price  = 350
#             teaser = "Packed with goodness to spice up your images"
#         }
#     }
#     items {
#         quantity = 69

#         coffee {
#             id     = 3
#             image  = "/nomad.png"
#             name   = "Nomadicano"
#             price  = 150
#             teaser = "Drink one today and you will want to schedule another"
#         }
#     }
# }

#######################################################
# Validate
#######################################################

curl -X GET -H "Authorization: ${HASHICUPS_TOKEN}" docker_compose_api_1:9090/orders/1