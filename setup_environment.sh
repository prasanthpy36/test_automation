#!/bin/bash

source ./utils.sh

# Function to install jq on Alpine
install_jq_alpine() {
  sudo apk update
  sudo apk add jq
  sudo apk add zlib-dev
  sudo apk add build-base openssl-dev libffi-dev bzip2-dev readline-dev sqlite-dev
}

# Function to install jq on Ubuntu
install_jq_ubuntu() {
  apt-get update
  apt-get install -y jq
  apt-get install -y zlib1g-dev
  apt-get install -y build-essential libssl-dev libffi-dev libbz2-dev libreadline-dev libsqlite3-dev
  apt-get install -y curl sudo
}

# Function to install jq on CentOS
install_jq_centos() {
  yum update -y
  yum install -y jq
  yum install -y zlib-devel
  yum groupinstall -y "Development Tools"
  yum install -y openssl-devel bzip2-devel libffi-devel sqlite-devel
  yum install -y curl sudo
}

# Function to install jq on SLES
install_jq_sles() {
  zypper refresh
  zypper install -y jq
  zypper install -y zlib-devel
  zypper install -y gcc libopenssl-devel libbz2-devel libffi-devel sqlite3-devel
  zypper install -y curl sudo
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
  if command -v pyenv &> /dev/null; then
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

install_docker() {
  if command_exists docker; then
    echo "Docker is already installed."
  else
    echo "Installing Docker..."
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get update
    sudo apt-get install -y docker-ce
    if [[ $(ps -p 1 -o comm=) == "systemd" ]]; then
      sudo systemctl enable docker
      sudo systemctl start docker
      sudo usermod -aG docker "$(whoami)"
      sudo systemctl stop docker
      sudo systemctl start docker
    else
      echo "System does not use systemd. Docker service will not be managed with systemd commands."
      sudo usermod -aG docker "$(whoami)"
    fi
  fi
}

# Function to check if a command exists
command_exists() {
  command -v "$1" &> /dev/null
}

# Function to install Docker on Alpine
install_docker_alpine() {
  sudo apk update
  sudo apk add docker
  sudo rc-update add docker boot
}
# Function to install Python on Alpine
install_python_alpine() {
  sudo apk update
  sudo apk add python3 py3-pip
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
