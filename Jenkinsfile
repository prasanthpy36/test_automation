pipeline {
    agent none
    stages {
        stage('Prepare') {
            steps {
                sh '''
                    git clean -f -d -x
                '''
            }
        }
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
                        image: ubuntu:20.04
                        command:
                        - cat
                        tty: true
                        resources:
                          requests:
                            memory: "8Gi"
                            cpu: "4"
                          limits:
                            memory: "12Gi"
                            cpu: "4"
                    """
                }
            }
            steps {
                container('test-container') {
                    script {
                        echo "Starting Git operations"
                        // Install git if it's not already installed in the image
                        sh 'apt-get update && apt-get install -y git make sudo'

                        // Clone the repository
                        git url: 'https://github.com/prasanthpy36/test_automation.git', branch: 'main', credentialsId: 'prasanthpy36'

                        // Run your make command
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