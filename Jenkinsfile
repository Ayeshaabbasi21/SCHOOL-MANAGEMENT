pipeline {
    agent any
    
    // REMOVE the parameters section - no manual trigger needed!
    
    environment {
        GH_REPO = 'Ayeshaabbasi21/SCHOOL-MANAGEMENT'
        GH_TOKEN_CRED = 'github-pat'
        COMPOSE_FILE = 'docker-compose.ci.yml'
        PROJECT_NAME = 'part2'
    }
    
    stages {
        stage('Clean Workspace') {
            steps {
                echo "🧹 Cleaning workspace from previous build..."
                cleanWs()
            }
        }
        
        stage('Checkout Latest Code') {
            steps {
                echo "🔄 Pulling latest code changes from GitHub"
                withCredentials([string(credentialsId: "${env.GH_TOKEN_CRED}", variable: 'GH_TOKEN')]) {
                    sh """
                        git clone https://${GH_TOKEN}@github.com/${env.GH_REPO}.git .
                    """
                }
            }
        }
        
        stage('Stop Previous Containers') {
            steps {
                echo "🛑 Stopping any running Part-II containers..."
                script {
                    sh """
                        docker-compose -f ${env.COMPOSE_FILE} -p ${env.PROJECT_NAME} down --remove-orphans || true
                    """
                }
            }
        }
        
        stage('Initialize Volumes') {
            steps {
                echo "📦 Copying latest code to volumes..."
                script {
                    sh """
                        chmod +x init-volumes.sh
                        ./init-volumes.sh
                    """
                }
            }
        }
        
        stage('Deploy Latest Version') {
            steps {
                echo "🚀 Deploying updated containers..."
                script {
                    sh """
                        docker-compose -f ${env.COMPOSE_FILE} -p ${env.PROJECT_NAME} up -d --build
                    """
                }
            }
        }
        
        stage('Health Check') {
            steps {
                echo "🏥 Verifying deployment..."
                script {
                    timeout(time: 2, unit: 'MINUTES') {
                        waitUntil {
                            try {
                                sh "curl -s -f http://localhost:7000 > /dev/null"
                                echo "✅ Backend deployment successful"
                                return true
                            } catch (Exception e) {
                                sleep 10
                                return false
                            }
                        }
                    }
                    
                    timeout(time: 3, unit: 'MINUTES') {
                        waitUntil {
                            try {
                                sh "curl -s -f http://localhost:8081 > /dev/null"
                                echo "✅ Frontend deployment successful"
                                return true
                            } catch (Exception e) {
                                sleep 10
                                return false
                            }
                        }
                    }
                }
            }
        }
    }
    
    post {
        always {
            echo "📊 Build completed"
            sh "docker-compose -f ${env.COMPOSE_FILE} -p ${env.PROJECT_NAME} ps || true"
        }
        success {
            echo """
            🎉 Automated Deployment Successful!
            
            📍 Your application is now live:
            Frontend: http://16.171.155.132:8081
            Backend: http://16.171.155.132:7000
            
            🔄 Triggered by: GitHub commit
            """
        }
        failure {
            echo "❌ Automated deployment failed!"
            sh "docker-compose -f ${env.COMPOSE_FILE} -p ${env.PROJECT_NAME} logs || true"
        }
    }
}
