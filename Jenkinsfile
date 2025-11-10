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

        stage('CI: Build & Deploy Part II') {
            steps {
                dir('repo') {
                    echo "🛠 Tearing down previous Part II containers (if any)"
                    sh 'docker-compose -f docker-compose.ci.yml down --remove-orphans'
                    
                    echo "🚀 Starting Part II CI containers (frontend 8081, backend 7000)"
                    sh 'docker-compose -f docker-compose.ci.yml up -d --build'
                    
                    sh 'docker system prune -f'
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
                    curl -s http://16.171.155.132:7000
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
    }
}


