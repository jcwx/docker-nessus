Docker - Nessus Container
==============================

This is an instance of a Docker container running Nessus.  There are a few options how you will prepare your environment to initiate the container, and another few options on how you will back up the Nessus configuration. 

I have only tested this Nessus container on a CoreOS host.  The systemd services for running the backups should run on any systemd based host.  If you're using a host that is using SysV/BSD init script system then you will have to create scripts by adapting the systemd service files and schedule them with cron.  

##### NOTE: I wrote a nessus.service file that I had not included in the instructions here nor provided the file itself. I added it and will provide a bit of insight into using it to maintain the Nessus service.  The service created will allow you to start and stop the container as well as starting the container on boot of the host system -- as long as the host system uses systemd, that is.

Steps
-----

* **Backup Present Nessus Install**: Create a tarball of the license or configuration being used currently. (if needed)

* **Create Docker Nessus Image**: Copy Dockerfile to Docker host and generate the image
 
* **Create Docker Nessus Container**: Run Docker Nessus image to create container
 
* **Configure Required Backup**: Copy provided systemd service files to CoreOS host to enable scheduled backup
 
### Backup Present Nessus Install

  * Run backup command found [here](https://gist.github.com/jcwx/a0e3199ad42fee393dae) on present Nessus installation
  * Retrieve the MAC address of the host where Nessus is running. (this MAC is needed in order to restore the configuration with the presently used license in a Docker container)

### Create Docker Nessus Image

  * copy nessus.tgz tarball to docker host
  * copy Nessus rpm to docker host
  * copy Dockerfile from this repo to your Docker host
  * review comments and alter Dockerfile to suit your needs
  * `docker build -t nessus .`

### Create Docker Nessus Container

  * use the MAC from the backup process
  * `docker run -p 8834:8834 --mac-address F4:CE:46:7E:71:B0 --name=nessus -d nessus`
 
You can now log into your running Nessus instance at:

https://(your-host-ip):8834

### Configure Required Backup

  * (as root) copy 'backup-nessus.service' and 'backup-nessus.timer' to /etc/systemd/system directory
  * run `systemctl daemon-reload && systemctl start backup-nessus.service` (should generate a nessus.tgz backup in '/home/core' or wherever you're running docker)
  * run `systemctl start backup-nessus.timer` (is configured to run every hour)
  * OPTIONAL - use S3 service files (backup-nessus-s3.service, backup-nessus-s3.timer) instead, follow notes in files



### Amazon S3 storage for backup <--- these instructions need to be cleaned up yet

You will need to retrieve the gof3r binary from 

https://github.com/rlmcpherson/s3gof3r

in order to complete this process.

Rename Dockerfile.Amazon_S3 to Dockerfile, and populate the environment keys, plus change the bucket to your destination from what I have here (my bucket is named 'nessus-bak')

-b nessus-bak  

'nessus.tgz' is the name of my backup tarball

-k nessus.tgz

#### Backup to S3 from running docker container

Populate the environment varibles with the keys for the IAM user you set up

export AWS_ACCESS_KEY_ID=AK*****************3Q

export AWS_SECRET_ACCESS_KEY=wk**************************************p

then run

`docker run --volumes-from c92e39881791 -v $(pwd):/backup debian tar -cvzf - --exclude=/opt/nessus/var/nessus/users/admin/reports /opt/nessus/var/nessus/users/ /opt/nessus/var/nessus/policies.db /opt/nessus/var/nessus/master.key /opt/nessus/var/nessus/global.db /opt/nessus/etc/nessus/nessus-fetch.db /opt/nessus/etc/nessus/nessusd.db /opt/nessus/etc/nessus/nessusd.conf.imported /opt/nessus/etc/nessus/nessusd.rules | ./gof3r put -b nessus-bak -k nessus.tgz`

Although this is rather wordy, the actual process of backing up and restoring the Nessus config is rather straightforward and simple.  
