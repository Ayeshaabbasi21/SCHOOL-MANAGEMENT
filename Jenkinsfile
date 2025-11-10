pipeline {
    agent any

    environment {
        DOCKER_COMPOSE = 'docker-compose.ci.yml'
        BACKEND_URL = 'http://localhost:7000/health'
    }

    stages {

        stage('Clean Old CI Containers & Workspace') {
            steps {
                echo "🧹 Stopping old CI containers and cleaning workspace..."
                sh """
                docker-compose -f ${DOCKER_COMPOSE} -p ci down -v || true
                sudo chown -R jenkins:jenkins $WORKSPACE || true
                sudo chmod -R u+rwX $WORKSPACE || true
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
            node {
                echo "🧹 Cleaning workspace..."
                cleanWs()
            }
        }
    }
}
