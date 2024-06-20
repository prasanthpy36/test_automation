FROM alpine:latest

# Install dependencies
RUN apk update && \
    apk add --no-cache curl jq kubectl git make bash

# Install k3d
RUN wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

# Set working directory
WORKDIR /app

# Copy the entire project
COPY . .

# Make sure all scripts have execute permissions
RUN chmod +x setup_environment.sh \
    scripts/cluster/create_clusters.sh \
    scripts/yaml/generate_yamls.sh \
    integration_tests/run_tests.sh

CMD ["bash"]
