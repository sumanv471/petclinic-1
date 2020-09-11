pipeline {
	agent { label 'master' }

	tools {
		maven 'M3.6.3'
	}
	
	environment {
		def tomcatDevIp = '18.222.190.164'
		def dockerDevIp = '172.31.5.14'
		def tomcatHome = '/home/ubuntu/tomcat8'
        def tomcatStart = "${tomcatHome}/bin/startup.sh"
        def tomcatStop = "${tomcatHome}/bin/shutdown.sh"
	}

	stages {
		stage('Checkout') {
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
            steps
            {
                scp -o StrictHostKeyChecking=no target/petclinic.war ec2-user@${dockerDevIp}:/home/ec2-user/docker/myweb.war
                scp -o StrictHostKeyChecking=no Dockerfile ec2-user@${dockerDevIp}:/home/ec2-user/docker/Dockerfile
                script                
                {
                                    sshPublisher(
                                            continueOnError: false, failOnError: true,
                                            publishers:  [
                                                sshPublisherDesc(
                                                    configName: 'dockerslave',
                                                    verbose: true,
                                                    transfers:[   
                                                        sshTransfer(                                                     
                                                                execCommand: "docker image prune -a --force && docker build -t petclinic . --no-cache && docker run -itd -p 8080:8080 petclinic"
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
