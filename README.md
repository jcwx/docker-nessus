These are the steps necessary to use the docker-nessus process on which I am working.

There are a few things that you might need to do first, depending on whether you have a
present Nessus install and want to retain the scheduled scans and logins or if you're
merely launching a fresh Nessus install.

#### Preparation

This Nessus docker setup allows you to import an existing configuration.  I was able to take the configuration from a Nessus 5 installation and install it, (license and all) on a fresh Nessus 6 docker container.  This included spoofing the MAC address of the Nessus 5 installation.  Allowed plugins to be downloaded.  Retained scheduled scans, plus policies.

To package the data needed from a present Nessus installation, you can use this command:

I don't believe these files exist in Nessus 5.

global.db-wal
global.db-shm

tar -cvzf nessus.tgz --exclude=/opt/nessus/var/nessus/users/admin/reports /opt/nessus/var/nessus/users/ /opt/nessus/var/nessus/policies.db /opt/nessus/var/nessus/master.key /opt/nessus/var/nessus/global.db /opt/nessus/etc/nessus/nessus-fetch.db /opt/nessus/etc/nessus/nessusd.db /opt/nessus/etc/nessus/nessusd.conf.imported /opt/nessus/etc/nessus/nessusd.rules

Place the nessus.tgz in the directory where your Dockerfile(s) are located. When the Nessus Docker container is built, the nessus.tgz file will be uncompressed and placed in /tmp

1. Create nessus-persist data container
  * use Dockerfile.nessus-persist (rename to Dockerfile)
  * sudo docker build -t core/nessus-persist .
  * docker create -v /opt/nessus-persist --name nessus-persist core/nessus-persist /bin/true
2. Create nessus data container
  * use Dockerfile
  * sudo docker build -t core/nessus .
  * docker run -p 8834:8834 --mac-address F4:CE:XX:XX:XX:XX -it --volumes-from nessus-persist core/nessus /bin/sh

When the Nessus container is run in step 2, it will leave a shell running where you can run /root/startup.sh.  This will check some things, move some data around and start the nessus daemon.  You will be able to connect to the instance at https://xx.xx.xx.xx:8834

You will also have to change the server where the Nessus rpm is acquired in the Dockerfile.  That's a local system I have, not a publicly available one. Could probably just move it to the directory where you're running the docker commands.

I intend on figuring out how to run the startup.sh script after the Nessus container is running, instead of running it manually in a shell.  Not sure what to do about that right now, but I'm sure I can come up with something.
