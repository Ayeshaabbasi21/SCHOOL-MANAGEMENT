pipeline {
  agent any

  environment {
    DOCKERHUB_CRED = 'dockerhub-creds'
    GITHUB_CRED = 'github-pat'
  }

  stages {
    stage('Checkout') {
      steps {
        withCredentials([string(credentialsId: env.GITHUB_CRED, variable: 'GH_TOKEN')]) {
          sh 'rm -rf repo || true'
          sh "git clone https://${GH_TOKEN}@github.com/Ayeshaabbasi21/SCHOOL-MANAGEMENT.git repo"
        }
      }
    }

    stage('CI Build') {
      steps {
        dir('repo') {
          sh 'docker-compose -f docker-compose.ci.yml down --remove-orphans || true'
          sh 'docker-compose -f docker-compose.ci.yml up --build --abort-on-container-exit --exit-code-from ci_frontend_build'
        }
      }
      post {
        always {
          dir('repo') {
            sh 'docker-compose -f docker-compose.ci.yml down --volumes || true'
          }
        }
      }
    }
  }

  post {
    success { echo "Pipeline succeeded" }
    failure { echo "Pipeline failed" }
    always { cleanWs() }
  }
}
