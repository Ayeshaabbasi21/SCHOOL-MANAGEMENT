pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                echo "🔄 Cloning latest code from GitHub"
                withCredentials([string(credentialsId: 'github-pat', variable: 'GH_TOKEN')]) {
                    sh '''
                        # Remove old repo folder
                        rm -rf repo
                        
                        # Clone fresh copy
                        git clone https://${GH_TOKEN}@github.com/Ayeshaabbasi21/SCHOOL-MANAGEMENT.git repo
                    '''
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

                    echo "🧹 Cleaning unused Docker resources"
                    sh 'docker system prune -f'
                }
            }
            post {
                always {
                    echo "✅ Part II containers should now be running"
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
