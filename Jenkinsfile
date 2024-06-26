pipeline {
    agent none
    stages {
        stage('Create Pod and Clone Repo') {
            agent {
                kubernetes {
                    label 'test-pod'
                    defaultContainer 'test-container'
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
                      - name: jnlp
                        image: jenkins/inbound-agent:latest
                        args:
                        - \${computer.jnlpmac}
                        - \${computer.name}
                        volumeMounts:
                        - mountPath: /home/jenkins/agent
                          name: workspace-volume
                    volumes:
                      - name: workspace-volume
                        emptyDir: {}
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
