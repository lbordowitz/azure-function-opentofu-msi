echo "Getting the current Azure subscription..."
SUBSCRIPTION_ID=$(az account show --query "id" -o tsv)

PREFIX="fctapp-opentofu"

echo "Destroying from subscription: $SUBSCRIPTION_ID with prefix $PREFIX"
tofu destroy -var "service_prefix=$PREFIX" -var "azure_subscription_id=$SUBSCRIPTION_ID" 

