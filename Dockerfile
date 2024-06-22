FROM docker:20.10-dind

# Install dependencies
RUN apk update && \
    apk add curl jq git make gettext sudo bash libc6-compat

# Create symbolic link for libresolv.so.2
RUN ln -sf /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2

# Install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" && \
    chmod +x ./kubectl && \
    mv ./kubectl /usr/local/bin/kubectl

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

# Run setup_environment.sh
RUN ./setup_environment.sh

# Start Docker daemon
CMD ["dockerd"]