pipeline {
    agent any
    stages {
        stage('Provision VM') {
            steps {
                script {
                    googleComputeEngineInstanceCreate(
                        projectId: 'noble-resolver-421403',
                        zone: 'us-central1-a',
                        instanceConfiguration: 'google-cloud-jenkins'
                    )
                }
            }
        }
        stage('Initialize Kubernetes Cluster') {
            steps {
                script {
                    sshCommand(remote: [user: 'root', host: 'VM_IP', identityFile: '/home/prasanthpy36', allowAnyHosts: true], command: '''
                        sudo apt-get update
                        sudo apt-get install -y apt-transport-https ca-certificates curl
                        curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -
                        sudo add-apt-repository "deb https://apt.kubernetes.io/ kubernetes-xenial main"
                        sudo apt-get update
                        sudo apt-get install -y kubelet kubeadm kubectl
                        sudo kubeadm init
                        mkdir -p $HOME/.kube
                        sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
                        sudo chown $(id -u):$(id -g) $HOME/.kube/config
                        kubectl apply -f https://docs.projectcalico.org/v3.14/manifests/calico.yaml
                    ''')
                }
            }
        }
        stage('Deploy DTM Services') {
            steps {
                script {
                    // Deploy services to Kubernetes
                    sh 'make setup'
                }
            }
        }
        stage('Test Services') {
            steps {
                script {
                    // Test DTM services
                    sh 'make test'
                }
            }
        }
        stage('Cleanup') {
            steps {
                script {
                    googleComputeEngineInstanceDelete(
                        projectId: 'noble-resolver-421403',
                        zone: 'us-central1-a',
                        instanceName: 'google-cloud-jenkins'
                    )
                }
            }
        }
    }
}
