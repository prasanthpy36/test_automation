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
                        image: dtmintigrationtest/kubernets-jenkins-config:1.0.0
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
                    echo "test-container"
//                     git 'https://github.com/prasanthpy36/test_automation.git'
                }
            }
        }
        stage('Setup and Test') {
            agent {
                kubernetes {
                    echo "kubernetes"
//                     label 'test-pod'
//                     defaultContainer 'jnlp'
                }
            }
            steps {
                container('test-container') {
                    echo "make all"
//                     sh 'make all'
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
