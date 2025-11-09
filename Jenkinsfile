pipeline {
    agent any

    environment {
        DOCKER_COMPOSE = 'docker-compose.ci.yml'
        BACKEND_URL = 'http://localhost:6000/health'
    }

    stages {
        stage('Clone Repository') {
            steps {
                echo "📥 Cloning repository..."
                git branch: 'main', url: 'https://github.com/Ayeshabbasi21/MERN-School-Management-System.git'
            }
        }

        stage('CI: Tear down previous Part II containers') {
            steps {
                echo "🛠 Tearing down Part II containers (if any)..."
                sh """
                # Remove previous containers if they exist
                docker rm -f ci_mongo ci_backend ci_frontend || true
                # Remove dangling networks to avoid conflicts
                docker network prune -f || true
                # Bring down any old containers from docker-compose
                docker-compose -f ${DOCKER_COMPOSE} down --remove-orphans -v || true
                """
            }
        }

        stage('CI: Build & Deploy Part II') {
            steps {
                echo "🚀 Starting Part II CI containers (frontend 8081, backend 6000)..."
                sh """
                docker-compose -f ${DOCKER_COMPOSE} up -d --build
                """
            }
        }

        stage('Wait for Services') {
            steps {
                echo "⏳ Waiting for MongoDB and Backend to be ready..."
                sh """
                # Wait for MongoDB
                for i in {1..10}; do
                    if docker exec ci_mongo mongo --eval 'db.runCommand({ ping: 1 })' >/dev/null 2>&1; then
                        echo "✅ MongoDB ready"
                        break
                    else
                        echo "⏳ Waiting for MongoDB..."
                        sleep 5
                    fi
                done

                # Wait for Backend
                for i in {1..10}; do
                    if curl -sS --fail ${BACKEND_URL} >/dev/null 2>&1; then
                        echo "✅ Backend healthy"
                        break
                    else
                        echo "⏳ Waiting for Backend..."
                        sleep 5
                    fi
                done
                """
            }
        }

        stage('Verify Deployment') {
            steps {
                echo "🔍 Verifying Frontend and Backend reachability..."
                sh """
                if curl -sS --fail ${BACKEND_URL} >/dev/null 2>&1; then
                    echo "✅ Backend reachable"
                else
                    echo "⚠ Backend not reachable"
                    exit 1
                fi
                """
            }
        }
    }

    post {
        success {
            echo "✅ CI Build and Deployment Successful!"
            echo "Frontend: http://16.171.155.132:8081"
            echo "Backend: http://16.171.155.132:6000"
        }
        failure {
            echo "❌ CI Build Failed! Check console logs."
        }
        always {
            echo "🧹 Cleaning up workspace..."
            cleanWs()
        }
    }
}
