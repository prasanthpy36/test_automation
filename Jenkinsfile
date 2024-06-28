pipeline {
    agent any
    stages {
        stage('Provision VM') {
            steps {
                script {
                    echo 'Starting VM provision...'
                    googleComputeEngineInstanceCreate(
                        credentialsId: 'google-cloud',
                        projectId: 'noble-resolver-421403',
                        zone: 'us-central1-a',
                        instanceConfiguration: 'google-cloud-jenkins'
                    )
                    echo 'VM provisioned.'
                }
            }
        }
        stage('Initialize Kubernetes Cluster') {
            steps {
                script {
                    echo 'Initializing Kubernetes Cluster...'
                    sshCommand(remote: [user: 'root', host: 'VM_IP', identityFile: '/home/prasanth/.ssh/id_rsa', allowAnyHosts: true], command: '''
                        // Your commands here
                    ''')
                    echo 'Kubernetes Cluster initialized.'
                }
            }
        }
        stage('Deploy DTM Services') {
            steps {
                script {
                    echo 'Deploying DTM Services...'
                    sh 'make setup'
                    echo 'DTM Services deployed.'
                }
            }
        }
        stage('Test Services') {
            steps {
                script {
                    echo 'Testing DTM Services...'
                    sh 'make test'
                    echo 'DTM Services tested.'
                }
            }
        }
        stage('Cleanup') {
            steps {
                script {
                    echo 'Starting cleanup...'
                    googleComputeEngineInstanceDelete(
                        credentialsId: 'google-cloud',
                        projectId: 'noble-resolver-421403',
                        zone: 'us-central1-a',
                        instanceName: 'google-cloud-jenkins'
                    )
                    echo 'Cleanup completed.'
                }
            }
        }
    }
}