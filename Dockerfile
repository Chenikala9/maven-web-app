FROM tomcat:9.0-jdk17-temurin

# Remove default applications
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy WAR file
COPY target/*.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080

CMD ["catalina.sh", "run"]
