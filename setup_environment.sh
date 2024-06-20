#!/bin/bash

source ./utils.sh

# Function to install jq on Ubuntu
install_jq_ubuntu() {
  apt-get update
  apt-get install -y jq
  apt-get install -y zlib1g-dev
  apt-get install -y build-essential libssl-dev libffi-dev libbz2-dev libreadline-dev libsqlite3-dev
  apt-get install -y curl
}

# Function to install jq on CentOS
install_jq_centos() {
  yum update -y
  yum install -y jq
  yum install -y zlib-devel
  yum groupinstall -y "Development Tools"
  yum install -y openssl-devel bzip2-devel libffi-devel sqlite-devel
  yum install -y curl
}

# Function to install jq on SLES
install_jq_sles() {
  zypper refresh
  zypper install -y jq
  zypper install -y zlib-devel
  zypper install -y gcc libopenssl-devel libbz2-devel libffi-devel sqlite3-devel
  zypper install -y curl
}

# Detect the operating system
OS=$(uname -s)

# Install jq based on the operating system
if [ "$OS" == "Linux" ]; then
  DISTRO=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
  if [[ "$DISTRO" == *"Ubuntu"* ]]; then
    install_jq_ubuntu
  elif [[ "$DISTRO" == *"CentOS"* ]]; then
    install_jq_centos
  elif [[ "$DISTRO" == *"SLES"* ]] || [[ "$DISTRO" == *"SUSE"* ]]; then
    install_jq_sles
  else
    echo "Unsupported Linux distribution. This script supports Ubuntu, CentOS, SLES, and SUSE."
    exit 1
  fi
else
  echo "Unsupported operating system. This script supports Linux."
  exit 1
fi

# Function to install a specific version of Python using pyenv
install_python() {
  PYTHON_VERSION=$(jq -r '.pythonVersion' configuration/services.json)
  echo "Checking if Python $PYTHON_VERSION is installed..."
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
}

# Install Python packages locally
install_python_packages() {
  echo "Installing Python packages from requirements.txt..."
  pip install --upgrade pip
  pip install -r requirements.txt
}

# Function to install Docker
# Install Docker (without sudo)
install_docker() {
  if command -v docker &> /dev/null; then
    echo "Docker is already installed."
  else
    echo "Installing Docker..."
    curl -fsSL https://get.docker.com/rootless | sh
    export PATH=$HOME/bin:$PATH
    export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock
    echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
    echo 'export DOCKER_HOST=unix://$XDG_RUNTIME_DIR/docker.sock' >> ~/.bashrc
    source ~/.bashrc
    dockerd-rootless-setuptool.sh install
    systemctl --user start docker
    systemctl --user enable docker
  fi
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
    if ! curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash; then
      echo "Failed to install k3d."
      exit 1
    fi
  else
    echo "k3d is already installed."
  fi
}

# Call the installation functions
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
python3.12 --version
pip --version
