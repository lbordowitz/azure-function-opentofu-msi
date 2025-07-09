echo "Checking Azure CLI version..."
az --version

echo "Checking OpenTofu version..."
tofu --version

echo "Logging in to Azure (please make sure to set your target subscription)..."
az login

echo "Initializing OpenTofu..."
tofu init
