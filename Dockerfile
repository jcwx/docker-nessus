# docker-nessus
#
# VERSION               0.0.1

FROM	centos:6
MAINTAINER JC Weir "jweir@ise.com"

# locally hosted web server providing image
RUN rpm -ivh http://10.22.88.22/Nessus-6.4.3-es6.x86_64.rpm

ADD ./nessus.tgz /tmp

EXPOSE 8834
COPY ./startup.sh /root/startup.sh
