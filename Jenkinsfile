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
                        image: alpine:latest
                        command:
                        - cat
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
                        sh 'apk update && apk add --no-cache git make bash'

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
                        sh 'apk update && apk add --no-cache make bash'
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
