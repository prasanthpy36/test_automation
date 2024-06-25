CONFIG_FILE := configuration/services.json
GENERATED_DIR := services/processed
TEST_REPORT := test_report.txt

# Default target
setup: install-tools create-docker-containers #create-clusters generate-yamls deploy wait-for-pods
all: setup test

# Target to install tools
install-tools:
	@echo "Running setup_environment.sh script..."
	@chmod +x setup_environment.sh
	@./setup_environment.sh

# Target to create Docker containers
create-docker-containers:
	@echo "Creating Docker containers from configuration..."
	@chmod +x setup_docker_services.sh
	@./setup_docker_services.sh

# Target to create k3d clusters
#create-clusters:
#	@echo "Creating k3d clusters from configuration..."
#	@chmod +x scripts/cluster/create_clusters.sh
#	@scripts/cluster/create_clusters.sh $(CONFIG_FILE)

# Target to generate YAMLs
#generate-yamls:
#	@echo "Generating YAMLs..."
#	@mkdir -p $(GENERATED_DIR)
#	@chmod +x scripts/yaml/generate_yamls.sh
#	@scripts/yaml/generate_yamls.sh $(CONFIG_FILE) $(GENERATED_DIR)

# Target to deploy to Kubernetes
#deploy: generate-yamls
#	@echo "Deploying services to k3d clusters..."
#	@find $(GENERATED_DIR) -name '*-deployment.yaml' | while read -r file; do \
#		kubectl apply -f $$file; \
#	done
#	@find $(GENERATED_DIR) -name '*-service.yaml' | while read -r file; do \
#		kubectl apply -f $$file; \
#	done

# Target to wait for pods to become ready
#wait-for-pods:
#	@echo "Waiting for pods to become ready..."
#	@sleep 10  # Initial sleep to give some time for pods to start
#	@TOTAL_PODS=$$(kubectl get pods --no-headers | wc -l); \
#	while [ $$(kubectl get pods --no-headers | grep -c 'Running') -lt $$TOTAL_PODS ]; do \
#		echo "Waiting for all pods to be in 'Running' state..."; \
#		sleep 5; \
#	done
#	@echo "All pods are up and running."

# Target to run tests
test:
	  @echo "Running tests and generating report in $(TEST_REPORT)"
	  @chmod +x integration_tests/run_tests.sh
	  @./integration_tests/run_tests.sh $(TEST_REPORT)
# Clean up generated files
#clean:
#	@echo "Deleting k3d clusters..."
#	@CLUSTERS=$(shell jq -r '.clusters[].name' $(CONFIG_FILE)); \
#	for cluster in $$CLUSTERS; do \
#		if k3d cluster list | grep -q $$cluster; then \
#			echo "Deleting k3d cluster $$cluster..."; \
#			k3d cluster delete $$cluster; \
#		fi; \
#	done
#	@echo "Removing generated files..."
#	@rm -f $(GENERATED_DIR)/*.yaml

# Phony targets
.PHONY: all install-tools create-docker-containers test