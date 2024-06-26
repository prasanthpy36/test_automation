pipeline {
    agent { label "34.29.155.60" }  // replace "gce-instance-label" with the label of your instance template

    environment {
        ROOT_DIR = "/root"
    }
    options {
        disableConcurrentBuilds()
        timeout(time: 40, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '5'))
    }
    stages {
        stage('Build') {
            steps {
                 echo "Starting Git operations"
                 // Clone all branches of the repository
                 git url: 'https://github.com/prasanthpy36/test_automation.git', credentialsId: 'prasanthpy36', branch: '**'
                 sh 'make setup'
            }
        }
        stage('Tests') {
            steps {
                sh 'make test'
            }
        }
        stage('Archive'){
            steps{
                archiveArtifacts artifacts: 'test_report.txt', onlyIfSuccessful: true
            }
        }
        stage('Clear') {
            steps {
                sh 'make clean'
            }
        }
    }
}