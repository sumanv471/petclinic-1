From tomcat:8-jre8 

# Maintainer
MAINTAINER "sumaanvemuri@gmail.com" 


# copy war file on to container 
COPY ./webapp.war /usr/local/tomcat/webapps

# tell docker what port to expose
EXPOSE 8080
