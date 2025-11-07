pipeline {
  agent any

  environment {
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

    stage('CI: Build & Deploy (docker-compose)') {
      steps {
        dir('repo') {
          // tear down any previous CI env, then bring up CI env detached
          sh 'docker-compose -f docker-compose.ci.yml down --remove-orphans || true'
          sh 'docker-compose -f docker-compose.ci.yml up -d --build'
        }
      }
    }

    stage('Verify') {
      steps {
        dir('repo') {
          // optional quick check: list containers and ports
          sh 'docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Ports}}"'
        }
      }
    }
  }

  post {
    success {
      echo "CI pipeline succeeded. Frontend should be at http://<HOST_IP>:8081 and backend at http://<HOST_IP>:6000"
    }
    failure {
      echo "CI pipeline failed. Check console logs."
    }
    always {
      cleanWs()
    }
  }
}
