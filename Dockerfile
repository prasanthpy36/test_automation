FROM ubuntu:20.04

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    jq \
    git \
    make \
    sudo \
    apt-utils \
    apt-transport-https \
    ca-certificates \
    zlib1g-dev \
    build-essential \
    libssl-dev \
    libffi-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev

# Install k3d
RUN curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x kubectl && \
    mv kubectl /usr/local/bin/ && \
    kubectl version --client

# Install Minikube
RUN curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && \
    chmod +x minikube && \
    mv minikube /usr/local/bin/

# Set working directory
WORKDIR /app

# Copy the entire project
COPY . .

# Make sure all scripts have execute permissions
RUN chmod +x setup_environment.sh \
    scripts/cluster/create_clusters.sh \
    scripts/yaml/generate_yamls.sh \
    integration_tests/run_tests.sh

# Set entrypoint
ENTRYPOINT ["bash"]
