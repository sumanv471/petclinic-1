From tomcat:8-jre8 

# Maintainer
MAINTAINER "sumaanvemuri@gmail.com" 


# copy war file on to container 
ADD ./docker/myweb.war /usr/local/tomcat/webapps/

# tell docker what port to expose
EXPOSE 8080

#To start tomcat service
CMD ["catalina.sh", "run"]
