#!/bin/sh

# Function to install jq and other required packages on Alpine
install_required_packages() {
  apk update
  apk add jq zlib-dev build-base libressl-dev libffi-dev bzip2-dev readline-dev sqlite-dev curl sudo
}

# Function to install Docker
install_docker() {
  if command -v docker > /dev/null; then
    echo "Docker is already installed."
  else
    echo "Installing Docker..."
    apk add docker
    rc-update add docker boot
    service docker start
  fi
}

# Function to install a specific version of Python using pyenv
install_python() {
  PYTHON_VERSION=$(jq -r '.pythonVersion' configuration/services.json)
  echo "Checking if Python $PYTHON_VERSION is installed..."
  if command -v pyenv > /dev/null; then
    if pyenv versions | grep -q "$PYTHON_VERSION"; then
      echo "Python $PYTHON_VERSION is already installed."
    else
      echo "Python $PYTHON_VERSION is not installed. Installing..."
      curl https://pyenv.run | bash
      export PATH="$HOME/.pyenv/bin:$PATH"
      eval "$(pyenv init --path)"
      eval "$(pyenv init -)"
      eval "$(pyenv virtualenv-init -)"
      pyenv install "$PYTHON_VERSION"
      pyenv global "$PYTHON_VERSION"
    fi
  else
    echo "pyenv is not installed. Installing pyenv first..."
    curl https://pyenv.run | bash
    export PATH="$HOME/.pyenv/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
    pyenv install "$PYTHON_VERSION"
    pyenv global "$PYTHON_VERSION"
  fi
}

# Install Python packages locally
install_python_packages() {
  echo "Installing Python packages from requirements.txt..."
  pip install --upgrade pip
  pip install -r requirements.txt
}

# Function to check if a command exists
command_exists() {
  command -v "$1" > /dev/null
}

# Install kubectl
install_kubectl() {
  if ! command_exists kubectl; then
    echo "Installing kubectl..."
    if ! curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"; then
      echo "Failed to download kubectl."
      exit 1
    fi
    chmod +x ./kubectl
    mv ./kubectl /usr/local/bin/kubectl
  else
    echo "kubectl is already installed."
  fi
}

# Install k3d
install_k3d() {
  if ! command_exists k3d; then
    echo "Installing k3d..."
    if ! wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash; then
      echo "Failed to install k3d."
      exit 1
    fi
  else
    echo "k3d is already installed."
  fi
}

# Call the installation functions
install_required_packages
install_docker
install_kubectl
install_k3d
install_python
install_python_packages

# Verify installations
echo "Verifying installations:"
docker --version
kubectl version --client
k3d version
jq --version
python3 --version
pip --version
