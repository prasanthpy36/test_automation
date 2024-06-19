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
                        image: alpine:latest
                        command:
                        - cat
                        tty: true
                    """
                }
            }
            steps {
                container('test-container') {
                    script {
                        echo 'Pod created'
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
                    echo "Cloning Repository"
                    git 'https://github.com/prasanthpy36/test_automation.git'
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
                    echo "Running setup and tests"
                    // Replace the following with the actual setup and test commands
                    sh 'make all'
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
