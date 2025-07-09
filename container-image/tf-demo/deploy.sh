DIR_NAME=$(dirname "$0")
cd $DIR_NAME

az login --identity

SUBSCRIPTION_ID=$(az account show --query "id" -o tsv)

tofu init
tofu plan \
    -var "azure_subscription_id=$SUBSCRIPTION_ID" \
    -var "backend_resource_group_name=$BACKEND_RESOURCE_GROUP_NAME" \
    -var "backend_storage_account_name=$BACKEND_STORAGE_ACCOUNT_NAME" \
    -var "backend_container_name=$BACKEND_CONTAINER_NAME" \
    -var "backend_key=$BACKEND_KEY" \
    -no-color