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
                echo "🧹 Removing previous Part 2 CI containers..."
                sh """
                # Stop and remove previous Part 2 containers
                docker ps -a --filter "name=ci_frontend" --filter "name=ci_backend" --filter "name=ci_mongo" -q | xargs -r docker rm -f
                
                # Remove Part 2 network if exists
                docker network ls -q --filter name=ci-network | xargs -r docker network rm
                
                # Remove Part 2 volume if exists
                docker volume ls -q --filter name=ci_mongo_data | xargs -r docker volume rm
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
