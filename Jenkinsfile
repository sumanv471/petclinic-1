pipeline {
        agent { label 'agent1' }
       // parameters { choice(name: 'branch', choices: ['master', 'anil'], description: 'Branches on petclinic') }
        tools {
		maven 'M3.6.3'
	    }
            stages {
                	stage('Checkout Branch Master') {
                	    steps {
				           git url: 'https://github.com/sumanv471/petclinic-1.git'
                	    }
                	}   
		            stage('Maven Build') {
		                input {
                                 message "Should we continue?"
                                ok "Yes, Proceed"
                            parameters {
                            string(name: 'PERSON', defaultValue: 'Mr Jenkins', description: 'Who should I say hello to?')
                            }
                        }
		                    steps {
	                            sh label: 'maven build', script: 'mvn clean package'	
		                    }
		            }
                    stage('Post Build Actions') {
                        parallel{
	    	                stage('Artifact') {
	    	                    steps {
	    	                        archiveArtifacts artifacts: 'target/*.?ar', followSymlinks: false
	    	                    }
	    	                }
		    	            stage('Tests') {
	    	                    steps {
		    	                    junit 'target/surefire-reports/*.xml'
	    	                    }
		    	            }
		    	            stage('Nexus uploader'){
		    	                steps{
		    	                    nexusArtifactUploader artifacts: [[artifactId: 'spring-petclinic', classifier: '', file: 'target/petclinic.war', type: 'war']], credentialsId: 'nexuscred', groupId: 'org.springframework.samples', nexusUrl: '40.87.89.207:8081', nexusVersion: 'nexus3', protocol: 'http', repository: 'maven-releases', version: "4.2.${BUILD_NUMBER}"
		    	                }
		    	            }
		    	            
                        }
                     }
            }
            post {
	        	success {
			    notify('Success')
		        }
		        failure {
			    notify('Failed')
		        }
		        aborted {
			    notify('Aborted')
		        }
	        }
}
def notify(status){
emailext (
to: "sumaanvemuri@gmail.com",
subject: "${status}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
body: """<p>${status}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]':</p>
<p>Check console output at <a href='${env.BUILD_URL}'>${env.JOB_NAME} [${env.BUILD_NUMBER}]</a></p>""",
)
}
