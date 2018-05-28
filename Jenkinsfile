pipeline {
  agent { dockerfile true }
  environment {
    AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
    AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
  }
  stages {
    stage('lint') {
      steps {
        sh 'make init'
        sh 'make check'
      }
    }
  }
}
