#######################################################
# Test error message
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
export HASHICUPS_PASSWORD=test1234 # Incorrect password on purpose

# Init and apply
terraform init && terraform apply --auto-approve