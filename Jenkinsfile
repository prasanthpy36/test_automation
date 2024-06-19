pipeline {
    agent none
    stages {
        stage('Create Pod') {
            agent {
                 kubernetes {
                    label 'test-pod'
                    defaultContainer 'jnlp'
                    yaml """
                    apiVersion: v1
                    kind: Pod
                    spec:
                      containers:
                      - name: test-container
                        image: ubuntu:latest
                        resources:
                          requests:
                            memory: "500Mi"
                            cpu: "500m"
                          limits:
                            memory: "1Gi"
                            cpu: "1"
                        command:
                        - cat
                        tty: true
                    """
                }
            }
            steps {
                container('test-container') {
                    script {
                        echo 'Pod created with Ubuntu image'
                    }
                }
            }
        }
        stage('Clone Repository') {
            agent {
                kubernetes {
                    label 'test-pod'
                    defaultContainer 'jnlp'
                }
            }
            steps {
                container('test-container') {
                    script {
                        echo "Cloning Repository"
                        // Install git if not already installed
                        sh 'apt-get update && apt-get install -y git'
                        // Clone the repository
                        git url: 'https://github.com/prasanthpy36/test_automation.git', branch: 'main'
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
                        // Install make if not already installed
                        sh 'apt-get update && apt-get install -y make'
                        // Run your make command or other setup/test commands
                        sh 'make all'
                    }
                }
            }
        }
    }
    post {
        always {
            // Optional cleanup stage
            cleanWs()
        }
    }
}
