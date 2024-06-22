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
                        image: dtmintigrationtest/kubernets-jenkins-config:ubuntu
                        securityContext:
                          privileged: true
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
//                         // Check Docker socket file
//                         echo "Checking Docker socket file..."
//                         sh 'ls -l /var/run/docker.sock'
//
//                         // Check Docker version
//                         echo "Checking Docker version..."
//                         sh 'docker version'
//
//                         // Check user permissions
//                         echo "Checking user permissions..."
//                         sh 'id'
//
//                         // Run your scripts
//                         sh './scripts/cluster/create_clusters.sh'
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
