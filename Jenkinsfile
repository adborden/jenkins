pipeline {
  agent { dockerfile true }
  environment {
    AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
    AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
    CI = 1
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
      environment {
        JENKINS_SSH_KEY_FILE = credentials('jenkins-web-ssh-key')
      }
      steps {
        milestone(1)
        sh 'make build'
      }
    }
    stage('deploy') {
      when { anyOf { branch 'master'; branch 'develop' } }
      steps {
        sh 'make plan'
        timeout(time: 30, unit: 'MINUTES') {
          input(message: 'Should we apply this plan to the infrastructure?', ok: 'Yes, I have reviewed the plan.')
        }
        lock('jenkins') {
          milestone(2)
          sh 'make apply'
        }
      }
    }
  }
}
