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
    make altinstall
    cd .. || exit
    rm -rf Python-"$PYTHON_VERSION"
    rm Python-"$PYTHON_VERSION".tgz
    # Set the default Python version to 3.12.3
    ln -sf /usr/local/bin/python3.12 /usr/bin/python
    ln -sf /usr/local/bin/pip3.12 /usr/bin/pip3
  fi
}

# Install Python packages
install_python_packages() {
  echo "Installing Python packages from requirements.txt..."
  /usr/local/bin/python3.12 -m pip install --upgrade pip
  /usr/local/bin/python3.12 -m pip install -r requirements.txt
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
      mkdir -p /usr/bin/docker
      curl -L https://download.docker.com/linux/static/stable/"${ARCH}"/docker-"${DOCKER_VERSION}".tgz -o docker.tgz
      tar -xzf docker.tgz -C /usr/bin/docker --strip-components=1
      rm docker.tgz
      # Remove existing symbolic links
      rm -f /usr/bin/docker /usr/bin/dockerd /usr/bin/docker-init /usr/bin/docker-proxy /usr/bin/containerd /usr/bin/containerd-shim /usr/bin/runc
      # Create new symbolic links
      ln -s /usr/bin/docker/docker /usr/bin/docker
      ln -s /usr/bin/docker/dockerd /usr/bin/dockerd
      ln -s /usr/bin/docker/docker-init /usr/bin/docker-init
      ln -s /usr/bin/docker/docker-proxy /usr/bin/docker-proxy
      ln -s /usr/bin/docker/containerd /usr/bin/containerd
      ln -s /usr/bin/docker/containerd-shim /usr/bin/containerd-shim
      ln -s /usr/bin/docker/runc /usr/bin/runc
      # Create Docker service file
      tee /etc/systemd/system/docker.service > /dev/null <<EOF
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
      systemctl daemon-reload
      systemctl enable docker
      systemctl start docker
    elif [[ "$DISTRO" == *"Ubuntu"* ]] || [[ "$DISTRO" == *"CentOS"* ]]; then
      if ! curl -fsSL https://get.docker.com -o get-docker.sh; then
        echo "Failed to download Docker installation script."
        exit 1
      fi
      if ! sh get-docker.sh; then
        echo "Failed to install Docker."
        exit 1
      fi
    else
      echo "Unsupported Linux distribution. This script supports Ubuntu, CentOS, SLES, and SUSE."
      exit 1
    fi
    usermod -aG docker "$USER"
    systemctl enable docker
    systemctl start docker
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
pip3.12 --version
