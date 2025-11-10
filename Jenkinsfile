kpipeline {
    agent any

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
                docker-compose -f docker-compose.ci.yml -p ci down -v --remove-orphans || true
                docker system prune -f || true
                """
            }
        }

        stage('Build & Deploy CI Containers') {
            steps {
                echo "🚀 Building and starting CI containers..."
                sh """
                docker-compose -f docker-compose.ci.yml -p ci up -d --build
                """
            }
        }

        stage('Wait for Backend Dependencies') {
            steps {
                echo "⏳ Waiting for backend dependencies to install..."
                sh """
                # Wait for backend container to be running
                for i in {1..30}; do
                    if docker ps --filter "name=ci_backend" --filter "status=running" | grep -q ci_backend; then
                        echo "✅ Backend container is running"
                        break
                    else
                        echo "⏳ Waiting for backend container to start... (\$i/30)"
                        sleep 5
                    fi
                    if [ \$i -eq 30 ]; then
                        echo "❌ Backend container failed to start"
                        docker-compose -f docker-compose.ci.yml -p ci logs backend
                        exit 1
                    fi
                done

                # Wait for node_modules to be installed
                echo "📦 Checking if backend dependencies are installed..."
                for i in {1..60}; do
                    if docker exec ci_backend sh -c "[ -d node_modules ] && echo 'found'" | grep -q found; then
                        echo "✅ Backend dependencies installed"
                        break
                    else
                        echo "⏳ Waiting for backend dependencies... (\$i/60)"
                        sleep 10
                    fi
                    if [ \$i -eq 60 ]; then
                        echo "❌ Backend dependencies took too long to install"
                        docker-compose -f docker-compose.ci.yml -p ci logs backend
                        exit 1
                    fi
                done
                """
            }
        }

        stage('Verify CI Backend') {
            steps {
                echo "🔍 Checking CI backend health..."
                sh """
                for i in {1..40}; do
                    if curl -s --max-time 10 http://16.171.155.132:7000/health >/dev/null 2>&1 || \
                       curl -s --max-time 10 http://16.171.155.132:7000 >/dev/null 2>&1; then
                        echo "✅ CI Backend is up and reachable!"
                        exit 0
                    else
                        echo "⏳ Waiting for backend to start... (attempt \$i/40)"
                        sleep 10
                    fi
                done
                echo "❌ CI Backend not reachable after 40 attempts!"
                echo "=== Debug Info ==="
                docker-compose -f docker-compose.ci.yml -p ci logs backend
                exit 1
                """
            }
        }

        stage('Final Verification') {
            steps {
                echo "🔎 Final container status..."
                sh """
                echo "=== Running Containers ==="
                docker ps --format "table {{.Names}}\\t{{.Status}}\\t{{.Ports}}"
                echo ""
                echo "=== Backend Response ==="
                curl -s -w "HTTP Status: %{http_code}\\n" http://16.171.155.132:7000/health || curl -s -w "HTTP Status: %{http_code}\\n" http://16.171.155.132:7000 || echo "Backend check failed"
                echo ""
                echo "✅ CI Deployment Complete"
                """
            }
        }
    }

    post {
        success {
            echo "🎉 CI Build & Deployment Successful!"
            echo "Frontend (CI): http://16.171.155.132:8081"
            echo "Backend (CI):  http://16.171.155.132:7000"
            echo "Backend Health: http://16.171.155.132:7000/health"
        }
        failure {
            echo "⚠️ CI pipeline failed. Check logs."
            script {
                sh """
                echo "=== All Container Logs ==="
                docker-compose -f docker-compose.ci.yml -p ci logs || true
                echo ""
                echo "=== Backend Logs ==="
                docker logs ci_backend --tail 50 || true
                echo ""
                echo "=== Container Status ==="
                docker-compose -f docker-compose.ci.yml -p ci ps || true
                """
            }
        }
        always {
            echo "🧹 Final workspace cleanup..."
            cleanWs()
        }
    }
}
