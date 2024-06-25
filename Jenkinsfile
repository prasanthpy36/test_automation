pipeline {
    agent none
    stages {
        stage('Create Pod and Clone Repo') {
            agent {
                kubernetes {
                    label 'test-pod'
                    defaultContainer 'dind-container'
                    yaml """
                    apiVersion: v1
                    kind: Pod
                    metadata:
                      labels:
                        jenkins/label: test-pod
                    spec:
                      containers:
                      - name: dind-container
                        image: docker:20.10.24-dind
                        securityContext:
                          privileged: true
                        env:
                        - name: DOCKER_TLS_CERTDIR
                          value: ""
                        volumeMounts:
                        - mountPath: /var/lib/docker
                          name: docker-lib
                      - name: test-container
                        image: dtmintigrationtest/kubernets-jenkins-config:ubuntu1
                        securityContext:
                          privileged: true
                        volumeMounts:
                        - mountPath: /var/run/docker.sock
                          name: docker-sock
                          readOnly: false
                        command: ["/bin/sh", "-c"]
                        args: ["while sleep 1000; do :; done"]
                      volumes:
                      - name: docker-sock
                        emptyDir: {}
                      - name: docker-lib
                        emptyDir: {}
                    """
                }
            }
            steps {
                container('dind-container') {
                    script {
                        echo "Starting Git operations"

                        // Clone all branches of the repository
                        checkout([
                            $class: 'GitSCM',
                            branches: [[name: '**']],
                            doGenerateSubmoduleConfigurations: false,
                            extensions: [],
                            submoduleCfg: [],
                            userRemoteConfigs: [[url: 'https://github.com/prasanthpy36/test_automation.git', credentialsId: 'prasanthpy36']]
                        ])
                         // Check Docker socket file
                         echo "Checking Docker socket file..."
                         sh 'ls -l /var/run/docker.sock'

                        // Check Docker version
                        echo "Checking Docker version..."
                        sh 'docker version'

                        // Check Docker socket file
                         echo "Checking Docker socket file..."
                         sh 'ls -l /var/run/docker.sock'

                        // Ensure privileged access and then run the make all command
                        echo "Running make all command with privileged access..."
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
