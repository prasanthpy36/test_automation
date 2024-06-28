pipeline {
    agent any
    environment {
        CLOUDSDK_CORE_PROJECT='noble-resolver-421403'
        CLIENT_EMAIL='jenkins-cloud@noble-resolver-421403.iam.gserviceaccount.com'
        GCLOUD_CREDS=credentials('google-cloud')
    }
    stages {
        stage('Provision VM') {
            steps {
                script {
                    echo 'Starting VM provision...'
                    googleComputeEngineInstanceCreate(
                        credentialsId: '${GCLOUD_CREDS}',
                        projectId: '${CLOUDSDK_CORE_PROJECT}',
                        zone: 'us-central1-a',
                        instanceConfiguration: '${CLOUDSDK_CORE_PROJECT}',
                    )
                    echo 'VM provisioned.'
                }
            }
        }
//         stage('Initialize Kubernetes Cluster') {
//             steps {
//                 script {
//                     echo 'Initializing Kubernetes Cluster...'
//                     sshCommand(remote: [user: 'root', host: 'VM_IP', identityFile: '/home/prasanth/.ssh/id_rsa', allowAnyHosts: true], command: '''
//                         // Your commands here
//                     ''')
//                     echo 'Kubernetes Cluster initialized.'
//                 }
//             }
//         }
//         stage('Deploy DTM Services') {
//             steps {
//                 script {
//                     echo 'Deploying DTM Services...'
//                     sh 'make setup'
//                     echo 'DTM Services deployed.'
//                 }
//             }
//         }
//         stage('Test Services') {
//             steps {
//                 script {
//                     echo 'Testing DTM Services...'
//                     sh 'make test'
//                     echo 'DTM Services tested.'
//                 }
//             }
//         }
        stage('Cleanup') {
            steps {
                script {
                    echo 'Starting cleanup...'
                    googleComputeEngineInstanceDelete(
                        credentialsId: '${GCLOUD_CREDS}',
                        projectId: '${CLOUDSDK_CORE_PROJECT}',
                        zone: 'us-central1-a',
                        instanceName: '${CLOUDSDK_CORE_PROJECT}'
                    )
                    echo 'Cleanup completed.'
                }
            }
        }
    }
}