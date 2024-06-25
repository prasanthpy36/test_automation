#!/bin/bash

# Load the configuration file
CONFIG_FILE="configuration/config.json"

# Create a Docker network if it doesn't already exist
if [ ! "$(docker network ls | grep service_network)" ]; then
   docker network create service_network
fi

# Read the services from the configuration file
services=$(jq -r 'keys[]' $CONFIG_FILE)

for service in $services
do
    # Define the Docker image, port, version, and name
    SERVICE_NAME=$(jq -r '.'$service'.name' $CONFIG_FILE)
    SERVICE_IMAGE=$(jq -r '.'$service'.image' $CONFIG_FILE)
    SERVICE_PORT=$(jq -r '.'$service'.port' $CONFIG_FILE)
    SERVICE_VERSION=$(jq -r '.'$service'.version' $CONFIG_FILE)

    # Pull the specific version of the Docker image from DockerHub
    docker pull $SERVICE_IMAGE:$SERVICE_VERSION || true

    # Check if the Docker image was pulled successfully
    if [ "$(docker images -q $SERVICE_IMAGE:$SERVICE_VERSION)" ]; then
        # Create and run a Docker container from the image
        docker run -d --name $SERVICE_NAME --network service_network -p $SERVICE_PORT:$SERVICE_PORT $SERVICE_IMAGE:$SERVICE_VERSION
    else
        echo "Failed to pull $SERVICE_IMAGE:$SERVICE_VERSION"
    fi
done