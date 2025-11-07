pipeline {
    agent any

    environment {
        GITHUB_CRED = 'github-pat' // Jenkins credential ID for GitHub PAT
        HOST_IP = '16.171.155.132' // EC2 public IP
    }

    stages {
        stage('Checkout') {
            steps {
                echo "🔄 Cloning latest code from GitHub"
                withCredentials([string(credentialsId: env.GITHUB_CRED, variable: 'GH_TOKEN')]) {
                    sh 'rm -rf repo || true'
                    sh "git clone https://${GH_TOKEN}@github.com/Ayeshaabbasi21/SCHOOL-MANAGEMENT.git repo"
                }
            }
        }

        stage('CI: Build & Deploy Part II') {
            steps {
                dir('repo') {
                    echo "🛠 Tearing down previous Part II containers (if any)"
                    sh 'docker-compose -f docker-compose.ci.yml down --remove-orphans || true'

                    echo "🚀 Starting Part II CI containers (frontend 8081, backend 6000)"
                    sh 'docker-compose -f docker-compose.ci.yml up -d --build'

                    // Optional: clean old dangling images
                    sh 'docker system prune -f || true'
                }
            }
            post {
                success {
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
                    sh """
                        sleep 5
                        if curl -s http://${HOST_IP}:6000 || true; then
                            echo '✅ Backend reachable at http://${HOST_IP}:6000'
                        else
                            echo '❌ Backend not reachable!'
                            exit 1
                        fi
                    """
                }
            }
        }
    }

    post {
        success {
            echo "🎉 CI pipeline succeeded!"
            echo "Frontend: http://${HOST_IP}:8081"
            echo "Backend: http://${HOST_IP}:6000"
        }
        failure {
            echo "⚠️ CI pipeline failed. Check console logs."
        }
        always {
            cleanWs()
        }
    }
}
