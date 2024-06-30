#!/bin/bash

source ./utils.sh

# Function to install jq on Ubuntu
install_jq_ubuntu() {
  sudo apt-get update
  sudo apt-get install -y jq
  sudo apt-get install -y zlib1g-dev
  sudo apt-get install -y build-essential libssl-dev libffi-dev libbz2-dev libreadline-dev libsqlite3-dev curl docker.io
}
# Function to install jq on Debian-based distributions (Ubuntu, Debian)
install_jq_debian_based() {
  sudo apt-get update
  sudo apt-get install -y jq
  sudo apt-get install -y zlib1g-dev
  sudo apt-get install -y build-essential libssl-dev libffi-dev libbz2-dev libreadline-dev libsqlite3-dev
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
  if [[ "$DISTRO" == *"Ubuntu"* ]] || [[ "$DISTRO" == *"Debian"* ]]; then
    install_jq_debian_based
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

# Function to install Docker
install_docker() {
    if command_exists docker; then
        echo "Docker is already installed."
    else
        echo "Installing Docker..."
        DISTRO=$(awk -F= '/^NAME/{print $2}' /etc/os-release)
        if [[ "$DISTRO" == *"SLES"* ]] || [[ "$DISTRO" == *"SUSE"* ]]; then
            DOCKER_VERSION=$(jq -r '.dockerVersion' configuration/services.json)
            ARCH=$(uname -m)
            sudo mkdir -p /usr/bin/docker
            curl -L https://download.docker.com/linux/static/stable/"${ARCH}"/docker-"${DOCKER_VERSION}".tgz -o docker.tgz
            sudo tar -xzf docker.tgz -C /usr/bin/docker --strip-components=1
            rm docker.tgz
            # Remove existing symbolic links
            sudo rm -f /usr/bin/docker /usr/bin/dockerd /usr/bin/docker-init /usr/bin/docker-proxy /usr/bin/containerd /usr/bin/containerd-shim /usr/bin/runc
            # Create new symbolic links
            sudo ln -s /usr/bin/docker/docker /usr/bin/docker
            sudo ln -s /usr/bin/docker/dockerd /usr/bin/dockerd
            sudo ln -s /usr/bin/docker/docker-init /usr/bin/docker-init
            sudo ln -s /usr/bin/docker/docker-proxy /usr/bin/docker-proxy
            sudo ln -s /usr/bin/docker/containerd /usr/bin/containerd
            sudo ln -s /usr/bin/docker/containerd-shim /usr/bin/containerd-shim
            sudo ln -s /usr/bin/docker/runc /usr/bin/runc
            # Create Docker service file
            sudo tee /etc/systemd/system/docker.service > /dev/null <<EOF
[Unit]
Description=Docker Application Container Engine
Documentation=https://docs.docker.com
After=network-online.target firewalld.service
Wants=network-online.target

[Service]
Type=notify
ExecStart=/usr/bin/dockerd
ExecReload=/bin/kill -s HUP \$MAINPID
TimeoutSec=0
RestartSec=2
Restart=always

[Install]
WantedBy=multi-user.target
EOF
            sudo systemctl daemon-reload
            sudo systemctl enable docker
            sudo systemctl start docker
        elif [[ "$DISTRO" == *"Ubuntu"* ]] || [[ "$DISTRO" == *"CentOS"* ]]; then
            if ! curl -fsSL https://get.docker.com -o get-docker.sh; then
                echo "Failed to download Docker installation script."
                exit 1
            fi
            if ! sudo sh get-docker.sh; then
                echo "Failed to install Docker."
                exit 1
            fi
        else
            echo "Unsupported Linux distribution. This script supports Ubuntu, CentOS, SLES, and SUSE."
            exit 1
        fi
        sudo usermod -aG docker "$USER"
        sudo systemctl enable docker
        sudo systemctl start docker
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
#install_python
#install_python_packages

# Verify installations
echo "Verifying installations:"
docker --version
kubectl version --client
k3d version
jq --version
#python --version
#pip3 --version