pipeline {
    agent {
        kubernetes {
            yaml """
            apiVersion: v1
            kind: Pod
            metadata:
                labels:
                    jenkins/label: 'test-pod'
            spec:
                containers:
                - name: jnlp
                  image: 'jenkins/inbound-agent:4.10-3'
                  args: ['\$(JENKINS_SECRET)', '\$(JENKINS_NAME)']
                  env:
                  - name: JENKINS_URL
                    value: "http://10.49.74.88:8080/"
                  - name: JENKINS_SECRET
                    value: "\$(JENKINS_SECRET)"
                  - name: JENKINS_AGENT_NAME
                    value: "test-pod"
                  - name: JENKINS_AGENT_WORKDIR
                    value: "/home/jenkins/agent"
                  - name: JENKINS_WEB_SOCKET
                    value: "true"
                  volumeMounts:
                  - mountPath: "/home/jenkins/agent"
                    name: workspace-volume
                - name: test-container
                  image: 'dtmintigrationtest/kubernets-jenkins-config:1.0.0'
                  command:
                  - cat
                  tty: true
                  volumeMounts:
                  - mountPath: "/home/jenkins/agent"
                    name: workspace-volume
                volumes:
                - name: workspace-volume
                  emptyDir: {}
            """
        }
    }

    environment {
        GIT_REPO_URL = 'https://github.com/prasanthpy36/test_automation.git'
        GIT_CREDENTIALS_ID = '9ba9ab61-2ba8-44ca-861d-349f4f65845f'
    }

    stages {
        stage('Clone Repository') {
            steps {
                container('jnlp') {
                    checkout([$class: 'GitSCM', branches: [[name: '*/main']],
                        doGenerateSubmoduleConfigurations: false,
                        extensions: [],
                        userRemoteConfigs: [[url: "${env.GIT_REPO_URL}", credentialsId: "${env.GIT_CREDENTIALS_ID}"]]
                    ])
                }
            }
        }

        stage('Setup Environment') {
            steps {
                container('test-container') {
                    sh 'chmod +x setup_environment.sh'
                    sh './setup_environment.sh'
                }
            }
        }

        stage('Run Tests') {
            steps {
                container('test-container') {
                    sh 'chmod +x run_tests.sh'
                    sh './run_tests.sh'
                }
            }
        }
    }

    post {
        always {
            node('jnlp') {
                cleanWs()
                echo 'Cleaning workspace'
            }
        }
    }
}