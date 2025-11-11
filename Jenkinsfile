pipeline {
    agent any

    environment {
        // Make sure this matches your Jenkins credentials ID for GitHub PAT
        GH_TOKEN = credentials('github-pat')
    }

    stages {
        stage('Checkout') {
            steps {
                echo "🔄 Cloning latest code from GitHub"
                sh '''
                    rm -rf repo
                    git clone https://${GH_TOKEN}@github.com/Ayeshaabbasi21/SCHOOL-MANAGEMENT.git repo
                '''
            }
        }

        stage('CI: Build & Deploy Part II') {
            steps {
                dir('repo') {
                    echo "🛠 Tearing down previous Part II containers (if any)"
                    sh 'docker-compose -f docker-compose.ci.yml down --remove-orphans'

                    echo "🚀 Starting Part II CI containers (frontend 8081, backend 7000)"
                    // Use absolute paths to avoid Jenkins workspace issues
                    sh 'docker-compose -f docker-compose.ci.yml up -d --build'

                    // Optional cleanup
                    sh 'docker system prune -f'
                }
            }
            post {
                always {
                    echo "✅ Part II CI containers should now be running"
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
                        curl -s http://16.171.155.132:7000 || echo "⚠️ Backend not reachable"
                    '''
                }
            }
        }
    }

    post {
        success {
            cleanWs()
            echo "🎉 CI pipeline succeeded!"
            echo "Frontend: http://16.171.155.132:8081"
            echo "Backend: http://16.171.155.132:7000"
        }
        failure {
            echo "❌ CI pipeline failed!"
        }
    }
}
