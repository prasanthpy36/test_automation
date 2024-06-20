FROM ubuntu:20.04

# Install dependencies
RUN apt-get update && \
    apt-get install -y curl jq kubectl git make

# Install k3d
RUN curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash

# Set working directory
WORKDIR /app

# Copy the entire project
COPY . .

# Make sure all scripts have execute permissions
RUN chmod +x setup_environment.sh \
    scripts/cluster/create_clusters.sh \
    scripts/yaml/generate_yamls.sh \
    integration_tests/run_tests.sh

# Execute setup_environment.sh
RUN ./setup_environment.sh

CMD ["bash"]