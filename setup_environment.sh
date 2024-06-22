#!/bin/bash

source ./utils.sh


#!/bin/bash

# Check if Minikube is running
if minikube status &> /dev/null
then
  echo "Minikube is running"
else
  echo "Minikube is not running, starting it now..."
  minikube start --vm-driver=none
fi

# Function to install jq on Ubuntu
install_jq_ubuntu() {
  sudo apt-get update
  sudo apt-get install -y jq
  sudo apt-get install -y zlib1g-dev
  sudo apt-get install -y build-essential libssl-dev libffi-dev libbz2-dev libreadline-dev libsqlite3-dev curl docker.io
}

# Function to install jq on CentOS
install_jq_centos() {
  sudo yum update -y
  sudo yum install -y jq
  sudo yum install -y zlib-devel
  sudo yum groupinstall -y "Development Tools"
  sudo yum install -y openssl-devel bzip2-devel libffi-devel sqlite-devel
}

# Function to install jq on SLES
install_jq_sles() {
  sudo zypper refresh
  sudo zypper install -y jq
  sudo zypper install -y zlib-devel
  sudo zypper install -y gcc libopenssl-devel libbz2-devel libffi-devel sqlite3-devel
}

# Function to install jq on Alpine
install_jq_alpine() {
  sudo apk update
  sudo apk add jq
  sudo apk add zlib-dev
  sudo apk add build-base openssl-dev bzip2-dev libffi-dev sqlite-dev
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
  elif [[ "$DISTRO" == *"Alpine"* ]]; then
    install_jq_alpine
  else
    echo "Unsupported Linux distribution. This script supports Ubuntu, CentOS, SLES, SUSE, and Alpine."
    exit 1
  fi
else
  echo "Unsupported operating system. This script supports Linux."
  exit 1
fi


# Function to install a specific version of Python
install_python() {
  PYTHON_VERSION=$(jq -r '.pythonVersion' configuration/services.json)
  echo "Checking if Python $PYTHON_VERSION is installed..."
  INSTALLED_PYTHON_VERSION=$(python3.12 -V 2>&1)
  if [ "$INSTALLED_PYTHON_VERSION" == "Python $PYTHON_VERSION" ]; then
    echo "Python $PYTHON_VERSION is already installed."
  else
    echo "Python $PYTHON_VERSION is not installed. Installing..."
    curl -O https://www.python.org/ftp/python/"$PYTHON_VERSION"/Python-"$PYTHON_VERSION".tgz
    tar -xzvf Python-"$PYTHON_VERSION".tgz
    cd Python-"$PYTHON_VERSION" || exit
    ./configure --enable-optimizations --with-ensurepip=install
    make
    sudo make altinstall
    # Install pip for Python 3.12
    sudo /usr/local/bin/python3.12 -m ensurepip --upgrade
    cd .. || exit
    rm -rf Python-"$PYTHON_VERSION"
    rm Python-"$PYTHON_VERSION".tgz
    # Set the default Python version to 3.12.3
    sudo ln -sf /usr/local/bin/python3.12 /usr/bin/python
    sudo ln -sf /usr/local/bin/pip3.12 /usr/bin/pip3
  fi
}

# Install Python packages
install_python_packages() {
  echo "Installing Python packages from requirements.txt..."
  python3.12 -m pip install --upgrade pip
  python3.12 -m pip install -r requirements.txt
}

# Function to install Docker
install_docker() {
  if command_exists docker; then
    echo "Docker is already installed."
    return
  fi

  echo "Installing Docker..."
  OS=$(uname -s)
  if [ "$OS" == "Linux" ]; then
    DISTRO=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
    if [[ "$DISTRO" == *"Ubuntu"* ]]; then
      install_docker_ubuntu
    elif [[ "$DISTRO" == *"CentOS"* ]]; then
      install_docker_centos
    elif [[ "$DISTRO" == *"SLES"* ]] || [[ "$DISTRO" == *"SUSE"* ]]; then
      install_docker_sles
    elif [[ "$DISTRO" == *"Alpine"* ]]; then
      install_docker_alpine
    else
      echo "Unsupported Linux distribution. This script supports Ubuntu, CentOS, SLES, SUSE, and Alpine."
      exit 1
    fi
  else
    echo "Unsupported operating system. This script supports Linux."
    exit 1
  fi
}

#install_docker_ubuntu() {
#  sudo apt-get update
#  sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
#  curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
#  sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
#  sudo apt-get update
#  sudo apt-get install -y docker-ce
#}
#
#install_docker_centos() {
#  sudo yum check-update
#  curl -fsSL https://get.docker.com/ | sh
#}
#
#install_docker_sles() {
#  sudo zypper refresh
#  sudo zypper install -y docker
#}
#
#install_docker_alpine() {
#  sudo apk update
#  sudo apk add docker
#  sudo rc-update add docker boot
#  sudo service docker start
#}

# Install kubectl
install_kubectl() {
  if ! command_exists kubectl; then
    echo "Installing kubectl..."
    if ! curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"; then
      echo "Failed to download kubectl."
      exit 1
    fi
    chmod +x ./kubectl
    sudo mv ./kubectl /usr/local/bin/kubectl
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
#install_docker
install_kubectl
install_k3d
#install_python
#install_python_packages

# Verify installations
echo "Verifying installations:"
docker --version
kubectl version --client
k3d version
jq --version
#python --version
#pip --version

