#!/bin/bash

CONFIG_FILE=$1

if [ ! -f "$CONFIG_FILE" ]; then
  echo "Configuration file $CONFIG_FILE not found!"
  exit 1
fi

# Read the clusters from the config file
CLUSTERS=$(jq -c '.clusters[]' "$CONFIG_FILE")

for cluster in $CLUSTERS; do
  CLUSTER_NAME=$(echo "$cluster" | jq -r '.name')
  AGENTS=$(echo "$cluster" | jq -r '.agents')
  PORTS=$(echo "$cluster" | jq -r '.ports | join(",")')

  # Check if the k3d cluster already exists
  if k3d cluster list | grep -q "$CLUSTER_NAME"; then
    echo "k3d cluster $CLUSTER_NAME already exists. Deleting..."
    k3d cluster delete "$CLUSTER_NAME"
    echo "Waiting for cluster to be fully deleted..."
    sleep 10  # Wait for 10 seconds
  fi

  # Create the k3d cluster
  echo "Creating k3d cluster $CLUSTER_NAME..."
  PORT_ARGS=""
  IFS=',' read -ra PORTS_ARR <<< "$PORTS"
  for port in "${PORTS_ARR[@]}"; do
      PORT_ARGS+=" -p $port"
  done
  k3d cluster create "$CLUSTER_NAME" --agents "$AGENTS" $PORT_ARGS
done
