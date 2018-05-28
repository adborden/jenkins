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
    stage('build') {
      when { anyOf { branch 'master'; branch 'develop' } }
      steps {
        milestone(1)
        sh 'make BRANCH_NAME=$BRANCH_NAME build'
      }
    }
    stage('deploy') {
      when { anyOf { branch 'master'; branch 'develop' } }
      steps {
        script {
          if (env.BRANCH_NAME == 'master') {
              sh 'terraform workspace select production terraform'
          } else {
              sh 'terraform workspace select default terraform'
          }
        }
        sh 'make BRANCH_NAME=$BRANCH_NAME plan'
        timeout(time: 30, unit: 'MINUTES') {
          input(message: 'Should we apply this plan to the infrastructure?', ok: 'Yes, I have reviewed the plan.')
        }
        lock('jenkins') {
          milestone(2)
          sh 'make apply'
        }
      }
    }
    stage('build') {
      steps {
        sh 'make build'
      }
    }
    stage('plan') {
      environment {
        AWS_SECRET_ACCESS_KEY=credentials('aws-secret-access-key')
        AWS_ACCESS_KEY_ID=credentials('aws-access-key-id')
      }
      steps {
        sh 'make plan'
      }
    }
    stage('deploy') {
      when {
        branch 'master'
      }
      environment {
        AWS_SECRET_ACCESS_KEY=credentials('aws-secret-access-key')
        AWS_ACCESS_KEY_ID=credentials('aws-access-key-id')
      }
      input {
        message "Would you like to apply this plan?"
        ok "Yes, I have reviewd the plan."
        submitter "adborden"
      }
      steps {
        sh 'make apply'
      }
    }
  }
}
