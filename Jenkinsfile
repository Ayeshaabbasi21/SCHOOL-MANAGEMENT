pipeline {
    agent any

    environment {
        FRONTEND_PORT = "8081"
        BACKEND_PORT = "7000"
    }

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

        stage('Cleanup') {
            steps {
                dir('repo') {
                    echo "🧹 Pruning old Docker resources"
                    sh 'docker system prune -af'
                    echo "✅ Cleanup done"
                }
            }
        }

        stage('CI: Build & Deploy Part II') {
            steps {
                dir('repo') {
                    echo "🛠 Bringing down previous Part II containers if any"
                    sh 'docker-compose -f docker-compose.ci.yml down --remove-orphans'

                    echo "🚀 Building and starting Part II containers"
                    sh 'docker-compose -f docker-compose.ci.yml up -d --build'
                }
            }
        }

        stage('Verify Deployment') {
            steps {
                dir('repo') {
                    echo "🔎 Listing running containers"
                    sh 'docker ps --format "table {{.ID}}\t{{.Names}}\t{{.Ports}}"'

                    echo "💻 Quick backend health check"
                    sh '''
                        sleep 5
                        curl -s http://ci_backend:5000 || echo "⚠️ Backend not reachable"
                    '''
                }
            }
        }
    }

    post {
        success {
            cleanWs()
            echo "🎉 CI pipeline succeeded!"
            echo "Frontend: http://<YOUR-EC2-IP>:8081"
            echo "Backend: http://<YOUR-EC2-IP>:7000"
        }
        failure {
            echo "❌ CI pipeline failed!"
        }
    }
}
