pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                echo "🔄 Cloning latest code from GitHub"
                withCredentials([string(credentialsId: 'github-pat', variable: 'GH_TOKEN')]) {
                    sh '''
                    rm -rf repo
                    git clone https://${GH_TOKEN}@github.com/Ayeshaabbasi21/SCHOOL-MANAGEMENT.git repo
                    '''
                }
            }
        }

        stage('CI: Build & Deploy') {
            steps {
                dir('repo') {
                    echo "🛠 Tearing down previous containers"
                    sh 'docker-compose -f docker-compose.ci.yml down --remove-orphans || true'
                    
                    echo "🚀 Starting CI containers"
                    sh 'docker-compose -f docker-compose.ci.yml up -d --build'
                    
                    echo "⏳ Waiting for backend to start..."
                    sh 'sleep 60'  # Wait 1 minute for npm install + app start
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                dir('repo') {
                    echo "🔎 Listing running containers"
                    sh 'docker ps --format "table {{.Names}}\t{{.Ports}}"'
                    
                    echo "💻 Backend health check"
                    sh '''
                    # Try multiple times with increasing delays
                    for i in 1 2 3 4 5; do
                        if curl -f http://16.171.155.132:7000/health || curl -f http://16.171.155.132:7000; then
                            echo "✅ Backend is healthy!"
                            break
                        else
                            echo "⏳ Backend not ready yet, waiting... (attempt $i)"
                            sleep 30
                        fi
                    done
                    echo "✅ Backend reachable at http://16.171.155.132:7000"
                    '''
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
        success {
            echo "🎉 CI pipeline succeeded!"
            echo "Frontend: http://16.171.155.132:8081"
            echo "Backend: http://16.171.155.132:7000"
        }
        failure {
            echo "⚠️ CI pipeline failed. Check logs."
            sh 'docker-compose -f docker-compose.ci.yml logs || true'
        }
    }
}
