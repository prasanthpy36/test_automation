pipeline {
    agent none
    stages {
        stage('Create Pod and Clone Repo') {
            agent {
                kubernetes {
                    label 'test-pod'
                    defaultContainer 'jnlp'
                    yaml """
                    apiVersion: v1
                    kind: Pod
                    metadata:
                      labels:
                        jenkins/label: test-pod
                    spec:
                      containers:
                      - name: test-container
                        image: dtmintigrationtest/kubernets-jenkins-config:1.0.0
                        command:
                        - cat
                        - /bin/bash
                        - -c
                        - |
                          apt-get update && apt-get install -y make
                          make install
                        tty: true
                        resources:
                          requests:
                            memory: "8Gi"
                            cpu: "4"
                          limits:
                            memory: "12Gi"
                            cpu: "6"
                    """
                }
            }
            steps {
                container('test-container') {
                    script {
                        echo "Starting Git operations"
                        // Install git if it's not already installed in the image
                        sh 'apt-get update && apt-get install -y git make'

                        // Clone the repository
                        git url: 'https://github.com/prasanthpy36/test_automation.git', branch: 'main', credentialsId: 'prasanthpy36'
                    }
                }
            }
        }
        stage('Setup and Test') {
            agent {
                kubernetes {
                    label 'test-pod'
                    defaultContainer 'jnlp'
                }
            }
            steps {
                container('test-container') {
                    script {
                        echo "Running setup and tests"
                        sh 'apt-get update && apt-get install -y git make sudo'
                        // Install Docker
                        sh '''
                        if ! command -v docker &> /dev/null
                        then
                            echo "Docker is not installed. Installing Docker..."
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
                        else
                            echo "Docker is already installed."
                        fi
                        '''
                        // Run your make command or other setup/test commands
                        sh 'make all'
                    }
                }
            }
        }
    }
    post {
        always {
            node('test-pod') {
                cleanWs()
            }
        }
    }
}
