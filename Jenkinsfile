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
                        image: dtmintigrationtest/kubernets-jenkins-config:3.0.0
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
                        volumeMounts:
                        - mountPath: /var/run/docker.sock
                          name: docker-sock
                      volumes:
                      - name: docker-sock
                        hostPath:
                          path: /var/run/docker.sock
                    """
                }
            }
            steps {
                container('test-container') {
                    script {
                        echo "Starting Git operations"
                        // Install git if it's not already installed in the image
                        sh 'apt-get update && apt-get install -y git make sudo'

                        // Clone all branches of the repository
                        checkout([
                            $class: 'GitSCM',
                            branches: [[name: '**']],
                            doGenerateSubmoduleConfigurations: false,
                            extensions: [],
                            submoduleCfg: [],
                            userRemoteConfigs: [[url: 'https://github.com/prasanthpy36/test_automation.git', credentialsId: 'prasanthpy36']]
                        ])

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