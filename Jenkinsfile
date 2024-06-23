// @Library('jenkins-pipeline-util') _

pipeline {
    agent any
    parameters {
        choice(
            name: 'ENVIRONMENT',
            description: 'Select Environment for Deployment',
            choices:['dev','stg','prd']
        )
        string (
            name: 'VERSION',
            defaultValue: '',
            description: 'Provide FRONTEND VERSION to Deploy/Upgrade/Remove such as: v0.5-69-g19bb5e0',
            trim: true
        )

        string (
            defaultValue: 'kafka',
            description: 'Provide CCA STACK Name to Deploy/Upgrade/Remove such as: xyzcorp',
            name: 'STACK',
            trim: true
        )

        choice(
            name: 'REGION',
            description: 'Select Environment for Deployment',
            choices:['east-us','west-us','all']
        )

        choice(
            name: 'HOSTS',
            description: 'Select Environment for Deployment',
            choices:['kafka01','kafka02', 'all']
        )

    }
    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/tajuddin-sonata/git-repo.git'
            }  
        }
        stage ('Deploy artifact') {
            steps {
                script {
                    currentBuild.displayName = "deploy-${ENVIRONMENT}-${STACK}-${REQUEST}-${BUILD_ID}"
                }
                withEnv([
                    "ENVIRONMENT=${params.ENVIRONMENT}",
                    "ARTIFACT_VERSION=${params.VERSION}",
                    "BUILD_ID=${env.BUILD_ID}",
                    "REGION=${params.REGION}",
                    "HOSTS=${params.HOSTS}"
                ]) {
                    sh 'bash deploy_releases.sh'
                }
            }
        }
    }
    post { 
        success {
            emailext (attachLog:true, body: '$DEFAULT_CONTENT', subject: '$DEFAULT_SUBJECT', to:'taj.070796@gmail.com')
            cleanWs()
        }
    }
}
