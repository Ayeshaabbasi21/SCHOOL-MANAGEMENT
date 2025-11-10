pipeline {
    agent any

    environment {
        DOCKER_COMPOSE = 'docker-compose.ci.yml'
        BACKEND_URL = 'http://localhost:7000/health'
        MAX_RETRIES = 12       // Wait up to 60s (12 x 5s)
    }

    stages {

        stage('Clean Old CI Containers & Workspace') {
            steps {
                echo "🧹 Stopping old CI containers and cleaning workspace..."
                sh """
                docker-compose -f ${DOCKER_COMPOSE} -p ci down -v || true
                sudo chown -R jenkins:jenkins \$WORKSPACE || true
                sudo chmod -R u+rwX \$WORKSPACE || true
                """
            }
        }

        stage('Clone Repository') {
            steps {
                echo "📥 Cloning repository..."
                git branch: 'main', url: 'https://github.com/Ayeshaabbasi21/SCHOOL-MANAGEMENT.git'
            }
        }

        stage('Build & Deploy CI Containers') {
            steps {
                echo "🚀 Building and starting CI containers..."
                sh """
                docker-compose -f ${DOCKER_COMPOSE} -p ci up -d --build
                """
            }
        }

        stage('Verify CI Backend') {
            steps {
                echo "🔍 Checking CI backend health..."
                script {
                    def healthy = false
                    for (int i = 1; i <= env.MAX_RETRIES.toInteger(); i++) {
                        try {
                            sh "curl -sS --fail ${BACKEND_URL}"
                            echo "✅ CI Backend is up!"
                            healthy = true
                            break
                        } catch (Exception e) {
                            echo "⏳ Waiting for CI backend... (${i}/${env.MAX_RETRIES})"
                            sleep 5
                        }
                    }
                    if (!healthy) {
                        error "❌ CI Backend not reachable after waiting!"
                    }
                }
            }
        }
    }

    post {
        success {
            echo "✅ CI Build & Deployment Successful!"
            echo "Frontend (CI): http://16.171.155.132:8081"
            echo "Backend (CI):  http://16.171.155.132:7000"
        }
        failure {
            echo "⚠️ CI pipeline failed. Check logs."
        }
        always {
            echo "🧹 Cleaning workspace..."
            cleanWs()
        }
    }
}
