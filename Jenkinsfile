pipeline {
    agent any

    environment {
        DOCKER_COMPOSE = 'docker-compose.ci.yml'
        BACKEND_CONTAINER = 'backend'  // name of your backend service in docker-compose
        BACKEND_URL = 'http://localhost:5000/health'  // inside container
    }

    stages {

        stage('Clean Old CI Containers & Workspace') {
            steps {
                echo "🧹 Stopping old CI containers and cleaning workspace..."
                sh """
                # Stop containers first
                docker-compose -f ${DOCKER_COMPOSE} -p ci down -v || true
                
                # Fix permission issues more safely
                docker system prune -f || true
                
                # Only change ownership if files exist and are owned by root
                find $WORKSPACE -user root -exec sudo chown jenkins:jenkins {} + 2>/dev/null || true
                find $WORKSPACE -type d -exec sudo chmod 755 {} + 2>/dev/null || true
                find $WORKSPACE -type f -exec sudo chmod 644 {} + 2>/dev/null || true
                """
                
                # Let Jenkins handle the main workspace cleanup
                cleanWs()
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
                for i in {1..20}; do
                    if docker-compose -f ${DOCKER_COMPOSE} exec -T ${BACKEND_CONTAINER} curl -sS --fail ${BACKEND_URL} >/dev/null 2>&1; then
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
            script {
                echo "🧹 Final workspace cleanup..."
                cleanWs()
            }
        }
    }
}
