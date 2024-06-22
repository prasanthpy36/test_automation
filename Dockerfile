FROM ubuntu:20.04

# Install dependencies
RUN apt-get update && \
    apt-get install -y curl jq git make sudo apt-utils

# Install Docker
RUN apt-get install -y docker.io

# Install k3d
RUN curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Update and install dependencies
RUN apt-get update && \
    apt-get install -y apt-transport-https ca-certificates curl

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/ && \
    kubectl version --client

# Install Minikube
RUN curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && \
    chmod +x minikube && \
    mv minikube /usr/local/bin/

# Set KUBECONFIG environment variable
ENV KUBECONFIG /path/to/your/kubeconfig/file

# Switch back to dialog for any ad-hoc use of apt-get
ENV DEBIAN_FRONTEND=dialog

# Set working directory
WORKDIR /app

# Copy the entire project
COPY . .

# Make sure all scripts have execute permissions
RUN chmod +x setup_environment.sh \
    scripts/cluster/create_clusters.sh \
    scripts/yaml/generate_yamls.sh \
    integration_tests/run_tests.sh

# Run setup_environment.sh
RUN ./setup_environment.sh