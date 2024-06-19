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
                    spec:
                      containers:
                      - name: test-container
                        image: ubuntu:latest
                        command:
                        - cat
                        tty: true
                        resources:
                          requests:
                            memory: "500Mi"
                            cpu: "500m"
                          limits:
                            memory: "1Gi"
                            cpu: "1"
                    """
                }
            }
            steps {
                container('test-container') {
                    script {
                        echo "Starting Git operations"
                        // Install git if it's not already installed in the image
                        sh 'apt-get update && apt-get install -y git'

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
