# sshd
#
# VERSION               0.0.1

FROM    centos-min.devwatchdog.com:5000/test

# https://github.com/jcwx
MAINTAINER JC Weir "jweir@ise.com"

# make sure the package repository is up to date
#RUN yum -y update
RUN rpm -ivh http://morrigan.devwatchdog.com/Nessus-5.2.5-es6.x86_64.rpm

#RUN mkdir /var/run/sshd
RUN echo 'root:screencast' |chpasswd

ADD ./startup.sh /root/startup.sh

EXPOSE 8834
CMD ["/bin/bash", "/root/startup.sh"]
