# sshd
#
# VERSION               0.0.1

#FROM    centos-min.devwatchdog.com:5000/test
FROM	centos:6
MAINTAINER JC Weir "jweir@ise.com"

# make sure the package repository is up to date
#RUN yum -y update
RUN rpm -ivh http://10.22.88.22/Nessus-6.4.3-es6.x86_64.rpm

ADD ./nessus.tgz /tmp

EXPOSE 8834
#RUN ["/bin/sh", "/root/startup.sh"]
COPY ./startup.sh /root/startup.sh
