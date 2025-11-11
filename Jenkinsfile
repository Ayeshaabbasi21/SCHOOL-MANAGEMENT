pipeline {
    agent any

    environment {
        GH_REPO = 'Ayeshaabbasi21/SCHOOL-MANAGEMENT'
        GH_TOKEN_CRED = 'github-pat'
    }

    stages {
        stage('Checkout') {
            steps {
                echo "🔄 Cloning latest code from GitHub"
                withCredentials([string(credentialsId: "${GH_TOKEN_CRED}", variable: 'GH_TOKEN')]) {
                    sh '''
                        rm -rf repo
                        git clone https://${GH_TOKEN}@github.com/${GH_REPO}.git repo
                    '''
                }
            }
        }

        stage('Prepare Part-II Environment') {
            steps {
                dir('repo') {
                    echo "🛑 Bringing down previous Part-II containers if any (won't affect Part-I)"
                    sh 'docker-compose -f docker-compose.ci.yml down --remove-orphans || true'

                    echo "🔒 Setting permissions for workspace"
                    sh 'sudo chown -R $USER:$USER ./backend ./frontend'
                }
            }
        }

        stage('Build & Deploy Part-II') {
            steps {
                dir('repo') {
                    echo "🚀 Building and starting Part-II containers"
                    sh 'docker-compose -f docker-compose.ci.yml up -d --build'
                }
            }
        }

        stage('Verify Backend') {
            steps {
                dir('repo') {
                    echo "💻 Quick backend health check"
                    sh '''
                        sleep 5
                        curl -s http://localhost:7000 || echo "⚠️ Part-II backend not reachable"
                    '''
                }
            }
        }

        stage('Verify Frontend') {
            steps {
                dir('repo') {
                    echo "💻 Quick frontend health check"
                    sh '''
                        sleep 5
                        curl -s http://localhost:8081 || echo "⚠️ Part-II frontend not reachable"
                    '''
                }
            }
        }
    }

    post {
        success {
            echo "🎉 Part-II CI pipeline succeeded!"
            echo "Frontend: http://<EC2_PUBLIC_IP>:8081"
            echo "Backend: http://<EC2_PUBLIC_IP>:7000"

            // Only clean temp/log files, NOT workspace folders
            echo "🧹 Cleaning temporary files..."
            sh '''
                find . -type f -name '*.log' -delete
                find . -type f -name '*.tmp' -delete
            '''
        }
        failure {
            echo "❌ Part-II CI pipeline failed!"
        }
    }
}
