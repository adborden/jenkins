pipeline {
  options { disableConcurrentBuilds() }
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
    stage('build') {
      when { branch 'master'; branch 'develop' }
      steps {
        sh 'make BRANCH_NAME=$BRANCH_NAME build'
      }
    }
    stage('plan') {
      when { branch 'master'; branch 'develop' }
      steps {
        script {
          if (env.BRANCH_NAME == 'master') {
              sh 'terraform workspace select production terraform'
          } else {
              sh 'terraform workspace select default terraform'
          }
        }
        sh 'make BRANCH_NAME=$BRANCH_NAME plan'
      }
    }
    stage('apply') {
      when { branch 'master'; branch 'develop' }
      input {
        message 'Should we apply this plan to the infrastructure?'
        ok 'Yes, I have reviewed the plan.'
        submitter 'adborden'
      }
      steps {
        echo 'psych!'
      }
    }
  }
}
