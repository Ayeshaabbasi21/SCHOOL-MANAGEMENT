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
                    echo "🛑 Bringing down previous Part-II containers (won't affect Part-I)"
                    sh 'docker-compose -f docker-compose.ci.yml down --remove-orphans || true'

                    echo "🔒 Fixing permissions and removing old node_modules safely"
                    sh '''
                        sudo chown -R $USER:$USER ./backend ./frontend || true
                        sudo rm -rf ./backend/node_modules ./frontend/node_modules || true
                    '''
                }
            }
        }

        stage('Install Dependencies') {
            steps {
                dir('repo/backend') {
                    echo "📦 Installing backend dependencies"
                    sh 'npm install'
                }
                dir('repo/frontend') {
                    echo "📦 Installing frontend dependencies"
                    sh 'npm install'
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
                        TIMEOUT=60
                        until curl -s http://localhost:7000; do
                          sleep 5
                          TIMEOUT=$((TIMEOUT-5))
                          if [ $TIMEOUT -le 0 ]; then
                            echo "⚠️ Part-II backend not reachable after 60s"
                            exit 1
                          fi
                        done
                    '''
                }
            }
        }

        stage('Verify Frontend') {
            steps {
                dir('repo') {
                    echo "💻 Quick frontend health check"
                    sh '''
                        TIMEOUT=120
                        until curl -s http://localhost:8081; do
                          sleep 5
                          TIMEOUT=$((TIMEOUT-5))
                          if [ $TIMEOUT -le 0 ]; then
                            echo "⚠️ Part-II frontend not reachable after 120s"
                            exit 1
                          fi
                        done
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

            echo "🧹 Cleaning temporary log files only"
            sh '''
                find . -type f -name '*.log' -delete || true
                find . -type f -name '*.tmp' -delete || true
            '''
        }
        failure {
            echo "❌ Part-II CI pipeline failed!"
        }
    }
}
