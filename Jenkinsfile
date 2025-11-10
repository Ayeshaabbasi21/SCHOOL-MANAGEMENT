pipeline {
    agent any

    environment {
        DOCKER_COMPOSE = 'docker-compose.ci.yml'
        BACKEND_URL = 'http://localhost:7000/health'
    }

    stages {
        stage('Clone Repository') {
            steps {
                echo "📥 Cloning repository..."
                git branch: 'main', url: 'https://github.com/Ayeshaabbasi21/SCHOOL-MANAGEMENT.git'
            }
        }

        stage('Clean Old CI Containers') {
            steps {
                echo "🧹 Removing previous CI containers..."
                sh """
                docker rm -f ci_mongo ci_backend ci_frontend || true
                docker network rm ci-network || true
                docker volume rm ci_mongo_data || true
                """
            }
        }

        stage('Build & Deploy CI (Part 2)') {
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
                sh """
                for i in {1..10}; do
                    if curl -sS --fail ${BACKEND_URL} >/dev/null 2>&1; then
                        echo "✅ CI Backend is up!"
                        exit 0
                    else
                        echo "⏳ Waiting for CI backend..."
                        sleep 5
                    fi
                done
                echo "❌ CI Backend not reachable!"
                exit 1
                """
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
