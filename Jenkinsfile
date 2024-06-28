pipeline {
    agent any
    environment {
        CLOUDSDK_CORE_PROJECT = 'noble-resolver-421403'
        GCLOUD_CREDS = credentials('google-cloud') // Ensure this matches your credentials ID in Jenkins
        SSH_USER = 'root' // Replace with your local system username
        ZONE = 'us-central1-a'
        MACHINE_TYPE = 'n1-standard-1'
        INSTANCE_PREFIX = 'jenkins-vm-instance' // Prefix for instance names
        PRIVATE_KEY_PATH = '/root/.ssh/id_rsa' // Replace with the actual path to your private key
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
                                sudo apt-get install -y apt-transport-https ca-certificates curl
                                sudo curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
                                sudo apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"
                                sudo apt-get update
                                sudo apt-get install -y kubelet kubeadm kubectl'
                    """

                    INSTANCE_IP = sh(script: "gcloud compute instances describe ${INSTANCE_NAME} --zone=${ZONE} --format='get(networkInterfaces[0].accessConfigs[0].natIP)'", returnStdout: true).trim()
                    echo "Instance IP: ${INSTANCE_IP}"
                }
            }
        }
        stage('Initialize Kubernetes Cluster') {
            steps {
                script {
                    echo 'Initializing Kubernetes Cluster...'
                    sshCommand(remote: [user: SSH_USER, host: INSTANCE_IP, identityFile: PRIVATE_KEY_PATH, allowAnyHosts: true], command: '''
                        sudo kubeadm init
                        mkdir -p $HOME/.kube
                        sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
                        sudo chown $(id -u):$(id -g) $HOME/.kube/config
                        kubectl apply -f https://docs.projectcalico.org/v3.14/manifests/calico.yaml
                    ''')
                    echo 'Kubernetes Cluster initialized.'
                }
            }
        }
        stage('Deploy DTM Services') {
            steps {
                script {
                    echo 'Deploying DTM Services...'
                    sshCommand(remote: [user: SSH_USER, host: INSTANCE_IP, identityFile: PRIVATE_KEY_PATH, allowAnyHosts: true], command: '''
                        kubectl apply -f /path/to/your/kubernetes-manifests.yaml
                    ''')
                    echo 'DTM Services deployed.'
                }
            }
        }
        stage('Test Services') {
            steps {
                script {
                    echo 'Testing DTM Services...'
                    sshCommand(remote: [user: SSH_USER, host: INSTANCE_IP, identityFile: PRIVATE_KEY_PATH, allowAnyHosts: true], command: '''
                        kubectl get pods
                    ''')
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
