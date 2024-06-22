#!/bin/bash

CONFIG_FILE=$1
GENERATED_DIR=$2
NAMESPACE="ioe-sit"

# Create the namespace if it doesn't exist
kubectl create namespace $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

if [ ! -f "$CONFIG_FILE" ]; then
  echo "Configuration file $CONFIG_FILE not found!"
  exit 1
fi

if [ ! -d "$GENERATED_DIR" ]; then
  mkdir -p "$GENERATED_DIR"
fi

# Read the clusters from the config file
CLUSTERS=$(jq -c '.clusters[]' "$CONFIG_FILE")

for cluster in $CLUSTERS; do
  SERVICES=$(echo "$cluster" | jq -c '.services[]')

  for service in $SERVICES; do
    SERVICE_NAME=$(echo "$service" | jq -r '.name')
    IMAGE=$(echo "$service" | jq -r '.image')
    TAG=$(echo "$service" | jq -r '.tag')
    CONTAINER_PORT=$(echo "$service" | jq -r '.containerPort')
    NODE_PORT=$(echo "$service" | jq -r '.nodePort')

    DEPLOYMENT_TEMPLATE="services/service-deployment.yaml.tpl"
    SERVICE_TEMPLATE="services/service.yaml.tpl"

    DEPLOYMENT_OUTPUT="$GENERATED_DIR/${SERVICE_NAME}-deployment.yaml"
    SERVICE_OUTPUT="$GENERATED_DIR/${SERVICE_NAME}-service.yaml"

    # Export variables for envsubst
    export SERVICE_NAME IMAGE TAG CONTAINER_PORT NODE_PORT

    # Generate the deployment YAML
    envsubst < "$DEPLOYMENT_TEMPLATE" > "$DEPLOYMENT_OUTPUT"

    # Generate the service YAML
    envsubst < "$SERVICE_TEMPLATE" > "$SERVICE_OUTPUT"

    # Apply the generated YAML files
    kubectl apply -f "$DEPLOYMENT_OUTPUT" --validate=false
    kubectl apply -f "$SERVICE_OUTPUT" --validate=false
  done
done
