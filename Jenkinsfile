pipeline {
    agent any
    environment {
        CLOUDSDK_CORE_PROJECT = 'noble-resolver-421403'
        GCLOUD_CREDS = credentials('google-cloud') // Ensure this matches your credentials ID in Jenkins
        SSH_USER = 'prasanthpy36' // Replace with your local system username
        ZONE = 'us-west1-a' // Change to another zone
        MACHINE_TYPE = 'n1-standard-1'
        INSTANCE_PREFIX = 'jenkins-vm-instance' // Prefix for instance names
        PRIVATE_KEY_CREDENTIALS_ID = 'prasanthpy36' // Replace with your actual SSH key credentials ID
        REPO_URL = 'https://github.com/prasanthpy36/test_automation.git' // Replace with your repository URL
    }
    stages {
        stage('Provision VM') {
            steps {
                script {
                    INSTANCE_NAME = "${INSTANCE_PREFIX}-${env.BUILD_ID}"
                    echo "Creating VM with name: ${INSTANCE_NAME}"

                    sh """
                        gcloud auth activate-service-account --key-file=\$GCLOUD_CREDS
                        gcloud compute instances create ${INSTANCE_NAME} \
                            --project=${CLOUDSDK_CORE_PROJECT} \
                            --zone=${ZONE} \
                            --machine-type=${MACHINE_TYPE} \
                            --image-family=ubuntu-2004-lts --image-project=ubuntu-os-cloud \
                            --metadata=startup-script='#!/bin/bash
                                sudo apt-get update
                                sudo apt-get install -y apt-transport-https ca-certificates curl git make'
                    """

                    INSTANCE_IP = sh(script: "gcloud compute instances describe ${INSTANCE_NAME} --zone=${ZONE} --format='get(networkInterfaces[0].accessConfigs[0].natIP)'", returnStdout: true).trim()
                    echo "Instance IP: ${INSTANCE_IP}"
                }
            }
        }
        stage('Clone Repository and Run Make') {
            steps {
                script {
                    echo 'Cloning repository and running make command...'
                    sshagent(['prasanthpy36']) {
                        sh """
                            ssh -o StrictHostKeyChecking=no ${SSH_USER}@${INSTANCE_IP} << EOF
                                git clone ${REPO_URL}
                                cd test_automation # Change this to your repository's directory
                                make # Assuming 'make install' is the target for your installations
                            EOF
                        """
                    }
                    echo 'Repository cloned and make command executed.'
                }
            }
        }
        stage('Test Services') {
            steps {
                script {
                    echo 'Testing DTM Services...'
                    sshagent(['prasanthpy36']) {
                        sh """
                            ssh -o StrictHostKeyChecking=no ${SSH_USER}@${INSTANCE_IP} << EOF
                                kubectl get pods
                            EOF
                        """
                    }
                    echo 'DTM Services tested.'
                }
            }
        }
        stage('Cleanup') {
            steps {
                script {
                    echo 'Starting cleanup...'
                    sh """
                        gcloud auth activate-service-account --key-file=\$GCLOUD_CREDS
                        gcloud compute instances delete ${INSTANCE_NAME} --zone=${ZONE} --quiet
                    """
                    echo 'Cleanup completed.'
                }
            }
        }
    }
}
