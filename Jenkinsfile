pipeline {
  agent {
    kubernetes {
      inheritFrom 'base-pod-template'
      yaml """
      apiVersion: v1
      kind: Pod
      metadata:
        labels:
          jenkins/label: 'test-pod'
      spec:
        containers:
        - name: jnlp
          image: 'jenkins/inbound-agent:3248.v65ecb_254c298-2'
          env:
          - name: JENKINS_URL
            value: "http://10.49.74.88:8080/"
          - name: JENKINS_SECRET
            value: "********"
          - name: JENKINS_AGENT_NAME
            value: "test-pod"
          - name: JENKINS_AGENT_WORKDIR
            value: "/home/jenkins/agent"
          - name: JENKINS_WEB_SOCKET
            value: "true"
          volumeMounts:
          - mountPath: "/home/jenkins/agent"
            name: workspace-volume
        volumes:
        - name: workspace-volume
          emptyDir: {}
      """
    }
  }

  stages {
    stage('Create Pod') {
      steps {
        echo 'Pod created'
      }
    }

    stage('Clone Repository') {
      steps {
        container('jnlp') {
          checkout([$class: 'GitSCM', branches: [[name: '*/main']],
            doGenerateSubmoduleConfigurations: false,
            extensions: [],
            userRemoteConfigs: [[url: 'https://github.com/prasanthpy36/test_automation.git', credentialsId: '9ba9ab61-2ba8-44ca-861d-349f4f65845f']]
          ])
        }
      }
    }

    stage('Setup and Test') {
      steps {
        container('jnlp') {
          // Add your setup and test steps here
          echo 'Setup and test steps go here'
        }
      }
    }
  }

  post {
    always {
      cleanWs()
      echo 'Cleaning workspace'
    }
  }
}
