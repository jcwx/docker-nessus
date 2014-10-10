# sshd
#
# VERSION               0.0.1

FROM centos:6

# https://github.com/jcwx
MAINTAINER JC Weir "jweir@ise.com"

# make sure the package repository is up to date

RUN rpm -ivh http://morrigan.devwatchdog.com/Nessus-5.2.5-es6.x86_64.rpm

# as alternative, download from Nessus - the home use
# requires acceptance of license
#
# http://www.tenable.com/products/nessus/select-your-operating-system
# Nessus-5.2.7-es6.x86_64.rpm
# 
# ADD Nessus-5.2.7-es6.x86_64.rpm /tmp
# RUN yum -y --nogpgcheck localinstall /tmp/Nessus-5.2.7-es6.x86_64.rpm
# RUN yum clean all

ADD ./startup.sh /root/startup.sh

EXPOSE 8834
CMD ["/bin/bash", "/root/startup.sh"]
