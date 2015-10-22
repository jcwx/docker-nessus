# nessus
#
# VERSION               0.0.1

FROM	centos:6
MAINTAINER JC Weir "jweir@ise.com"

# get Nessus rpm (or whatever installation package you need)
#
# http://www.tenable.com/products/nessus/select-your-operating-system
#
RUN rpm -ivh http://10.22.88.22/Nessus-6.4.3-es6.x86_64.rpm

# or store the image locally and install from there
#
# RUN rpm -ivh Nessus-6.4.3-es6.x86_64.rpm

# add the locally stored backup to the docker image
#
ADD ./nessus.tgz /

VOLUME /opt/nessus

EXPOSE 8834
CMD ["/opt/nessus/sbin/nessus-service"]
