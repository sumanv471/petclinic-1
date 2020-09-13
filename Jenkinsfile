pipeline {
	agent { label 'master' }

	tools {
		maven 'M3.6.3'
	}
	
	environment {
		def tomcatDevIp = '18.222.190.164'
		def dockerDevIp = '3.22.249.107'
		def tomcatHome = '/home/ubuntu/tomcat8'
        def tomcatStart = "${tomcatHome}/bin/startup.sh"
        def tomcatStop = "${tomcatHome}/bin/shutdown.sh"
	}

	stages {
		
		stage('Maven Build') {
			input {
                message "Should we continue?"
                ok "Yes, Proceed"
                parameters {
                    string(name: 'PERSON', defaultValue: 'Mr Jenkins', description: 'Who should I say hello to?')
                }
            }
			steps {
				echo "Hello, ${PERSON}, nice to meet you."
				sh label: '', script: 'mvn clean package'
			}
		}
		stage('Post Build Actions') {
			parallel {
				stage('Archive Artifacts') {
					steps {
						archiveArtifacts artifacts: 'target/*.?ar', followSymlinks: false
					}
				}

				stage('Test Results') {
					steps {
						junit 'target/surefire-reports/*.xml'
					}
				}
				
				stage('Nexus Uploader') {
					steps {
						nexusArtifactUploader artifacts: [[artifactId: 'spring-petclinic', classifier: '', file: 'target/petclinic.war', type: 'war']], credentialsId: 'nexuscred', groupId: 'org.springframework.samples', nexusUrl: '18.222.190.164:8081', nexusVersion: 'nexus3', protocol: 'http', repository: 'maven-releases', version: "1.0.${BUILD_NUMBER}"
					}
				}
				
				stage("bulding docker image and deploy") {
                 		   steps {
              	 				sshagent(['Docker_ec2-user']) {
							sh "scp -o StrictHostKeyChecking=no target/petclinic.war ec2-user@${dockerDevIp}:/home/ec2-user/docker/myweb.war"	   
				   		        sh "scp -o StrictHostKeyChecking=no Dockerfile ec2-user@${dockerDevIp}:/home/ec2-user/docker/Dockerfile"
						 sshPublisher(
                                            continueOnError: false, failOnError: true,
                                            publishers:  [
                                                sshPublisherDesc(
                                                    configName: 'dockerslave',
                                                    verbose: true,
                                                    transfers:[   
                                                        sshTransfer(
								execCommand:"docker stop $(docker ps -a -q) && docker rm -f $(docker ps -a -q) && cd docker && docker build -t petclinic . --no-cache && docker run -itd --name petclinic -p 8080:8080 petclinic"
                                                        )
                                                    ]
                                                )
                                            ]
                                    )        
						
						
						
						}
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
