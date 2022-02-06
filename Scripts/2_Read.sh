########################################################
# Clone boilerplate for provider creation
########################################################
git clone --branch boilerplate https://github.com/hashicorp/terraform-provider-hashicups
cd terraform-provider-hashicups

# Healthcheck from within the docker network reaches port over local, NOT 19090
curl docker_compose_api_1:9090/health

# Checkout folder structure
tree -L 3

########################################################
# Build provider
########################################################
# Note, at this point our Go code can't resolve the packages
# Create empty go.mod file
go mod init terraform-provider-hashicups

# Create vendor directory for downloading dependencies
go mod vendor

# Note - now the go code will resolve the packages

# Build via makefile
make build
# Terraform searches for plugins in the format of terraform-<TYPE>-<NAME>. 
# For us -
#   type: "provider" 
#   name "hashicups"

# Test execute binary
./terraform-provider-hashicups

########################################################
# Define coffees data resource
########################################################
# Get coffee schema
curl docker_compose_api_1:9090/coffees
# [{"id":1,"name":"Packer Spiced Latte","teaser":"Packed with goodness to spice up your images","description":"","price":350,"image":"/packer.png","ingredients":[{"ingredient_id":1},{"ingredient_id":2},{"ingredient_id":4}]},{"id":2,"name":"Vaulatte","teaser":"Nothing gives you a safe and secure feeling like a Vaulatte","description":"","price":200,"image":"/vault.png","ingredients":[{"ingredient_id":1},{"ingredient_id":2}]},{"id":3,"name":"Nomadicano","teaser":"Drink one today and you will want to schedule another","description":"","price":150,"image":"/nomad.png","ingredients":[{"ingredient_id":1},{"ingredient_id":3}]},{"id":4,"name":"Terraspresso","teaser":"Nothing kickstarts your day like a provision of Terraspresso","description":"","price":150,"image":"terraform.png","ingredients":[{"ingredient_id":1}]},{"id":5,"name":"Vagrante espresso","teaser":"Stdin is not a tty","description":"","price":200,"image":"vagrant.png","ingredients":[{"ingredient_id":1}]},{"id":6,"name":"Connectaccino","teaser":"Discover the wonders of our meshy service","description":"","price":250,"image":"consul.png","ingredients":[{"ingredient_id":1},{"ingredient_id":5}]}]

########################################################
# Test the provider
########################################################
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

# Initialize
terraform init

# Plan
terraform plan

# Apply
terraform apply --auto-approve