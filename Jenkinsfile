pipeline{
    agent any
    stages{
        stage('git checkout'){
            steps{
                sh '''
                    git clone 'https://github.com/godithipradeep/test.git'
                    '''
            }
        }
        stage('run nginx playbook'){
            steps{
                ansiblePlaybook credentialsId: 'ansible', disableHostKeyChecking: true, installation: 'ansible', inventory: 'test/inventory', playbook: 'test/nginxplaybook.yml'
            }
        }
    }
}