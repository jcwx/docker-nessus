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

Place the nessus.tgz in the directory where your Dockerfile is located. When the Nessus Docker container is built, the nessus.tgz file will be extracted to the proper location

Also, you will need to know the MAC address of the host where the Nessus backup was created.  This is necessary to install the backup and allow it to run.  

#### Create nessus data container
  * use Dockerfile
  * sudo docker build -t core/nessus .
  * docker run -p 8834:8834 --mac-address F4:CE:XX:XX:XX:XX -d core/nessus

You will be able to connect to the instance at https://xx.xx.xx.xx:8834

You will also have to change the server where the Nessus rpm is acquired in the Dockerfile.  That's a local system I have, not a publicly available one. Could probably just move it to the directory where you're running the docker commands.

If you're on your first install, you'll have to create an empty nessus.tgz file.  The Dockerfile is looking for one, and will fail if one is not found.

To create a backup locally from the running docker container:

docker run --volumes-from (CONTAINER ID) -v $(pwd):/backup debian tar -cvzf /backup/nessus.tgz --exclude=/opt/nessus/var/nessus/users/admin/reports /opt/nessus/var/nessus/users/ /opt/nessus/var/nessus/policies.db /opt/nessus/var/nessus/master.key /opt/nessus/var/nessus/global.db /opt/nessus/etc/nessus/nessus-fetch.db /opt/nessus/etc/nessus/nessusd.db /opt/nessus/etc/nessus/nessusd.conf.imported /opt/nessus/etc/nessus/nessusd.rules

### Amazon S3 storage for backup

You will need to retrieve the gof3r binary from 

https://github.com/rlmcpherson/s3gof3r

in order to complete this process.

Rename Dockerfile.Amazon_S3 to Dockerfile, and populate the environment keys, plus change the bucket to your destination from what I have here (my bucket is named 'nessus-bak')

-b nessus-bak  

'nessus.tgz' is the name of my backup tarball

-k nessus.tgz

Backup to S3 from running docker container

Populate the environment varibles with the keys for the IAM user you set up

export AWS_ACCESS_KEY_ID=AK*****************3Q

export AWS_SECRET_ACCESS_KEY=wk**************************************p

then run

docker run --volumes-from c92e39881791 -v $(pwd):/backup debian tar -cvzf - --exclude=/opt/nessus/var/nessus/users/admin/reports /opt/nessus/var/nessus/users/ /opt/nessus/var/nessus/policies.db /opt/nessus/var/nessus/master.key /opt/nessus/var/nessus/global.db /opt/nessus/etc/nessus/nessus-fetch.db /opt/nessus/etc/nessus/nessusd.db /opt/nessus/etc/nessus/nessusd.conf.imported /opt/nessus/etc/nessus/nessusd.rules | ./gof3r put -b nessus-bak -k nessus.tgz

Although this is rather wordy, the actual process of backing up and restoring the Nessus config is rather straightforward and simple.  
