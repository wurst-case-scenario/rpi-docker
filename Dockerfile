#
# see https://github.com/netflash/docker-activiti/blob/master/Dockerfile
#
FROM hypriot/rpi-java:1.7.0-jdk
MAINTAINER Daniel Wurst <daniel.wurst@web.de>

# Update packages in single line to enable caching (see http://crosbymichael.com/dockerfile-best-practices.html) 
# ATTENTION: Consecutive package updates may fail (see https://docs.docker.com/engine/userguide/eng-image/dockerfile_best-practices/)
RUN apt-get update

ENV TOMCAT_VERSION 8.0.30
RUN apt-get install -y wget && \
	wget --no-check-certificate -O /tmp/catalina.tar.gz http://archive.apache.org/dist/tomcat/tomcat-8/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz && \
	tar xzf /tmp/catalina.tar.gz -C /opt && \
	ln -s /opt/apache-tomcat-${TOMCAT_VERSION} /opt/tomcat && \
	rm /tmp/catalina.tar.gz
 
ENV ACTIVITI_VERSION 5.19.0.2
RUN apt-get install -y unzip && \
	wget --no-check-certificate -O /tmp/activiti.zip https://github.com/Activiti/Activiti/releases/download/${ACTIVITI_VERSION}/activiti-${ACTIVITI_VERSION}.zip && \
	unzip /tmp/activiti.zip -d /opt/activiti && \
	rm /tmp/activiti.zip && \
	rm -rf /opt/tomcat/webapps/examples && \
	rm -rf /opt/tomcat/webapps/docs && \
	unzip /opt/activiti/activiti-${ACTIVITI_VERSION}/wars/activiti-explorer.war -d /opt/tomcat/webapps/activiti-explorer && \
	unzip /opt/activiti/activiti-${ACTIVITI_VERSION}/wars/activiti-rest.war -d /opt/tomcat/webapps/activiti-rest

COPY resources /opt/rpi-activiti
RUN ln -sf /opt/rpi-activiti/config/tomcat/* /opt/tomcat/conf && \
	ln -f /opt/rpi-activiti/config/activiti/* /opt/tomcat/webapps/activiti-explorer/WEB-INF/classes && \
	ln -f /opt/rpi-activiti/config/activiti/* /opt/tomcat/webapps/activiti-rest/WEB-INF/classes

# Define default startup command
CMD ["/opt/rpi-activiti/startup.sh"]