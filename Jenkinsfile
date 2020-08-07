pipeline {
	agent { label 'master' }

	tools {
		maven 'M3.6.3'
	}
	
	environment {
		def tomcatDevIp = '13.72.74.55'
		def tomcatHome = '/home/sonar/tomcat8'
        def tomcatStart = "${tomcatHome}/bin/startup.sh"
        def tomcatStop = "${tomcatHome}/bin/shutdown.sh"
	}

	stages {
		stage('Checkout') {
			steps {
				git url: 'https://github.com/akmaharshi/petclinic.git'
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
						nexusArtifactUploader artifacts: [[artifactId: 'spring-petclinic', classifier: '', file: 'target/petclinic.war', type: 'war']], credentialsId: 'nexuscred', groupId: 'org.springframework.samples', nexusUrl: '23.96.98.151:8081', nexusVersion: 'nexus3', protocol: 'http', repository: 'maven-releases', version: "4.2.${BUILD_NUMBER}"
					}
				}
				
				stage('Deploy') {
					steps {
                                		sh "scp -o StrictHostKeyChecking=no target/petclinic.war sonar@${tomcatDevIp}:/home/sonar/tomcat8/webapps/myweb.war"
                                		sh "ssh sonar@${tomcatDevIp} ${tomcatStop}"
                                		sh "ssh sonar@${tomcatDevIp} ${tomcatStart}"
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
      to: "anilmaharshi.p@gmail.com",
      subject: "${status}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
      body: """<p>${status}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]':</p>
        <p>Check console output at <a href='${env.BUILD_URL}'>${env.JOB_NAME} [${env.BUILD_NUMBER}]</a></p>""",
    )
}
