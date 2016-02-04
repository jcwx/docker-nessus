Docker - Nessus Container
==============================

This is an instance of a Docker container running Nessus.  There are a few options how you will prepare your environment to initiate the container, and another few options on how you will back up the Nessus configuration. 

I have only tested this Nessus container on a CoreOS host.  The systemd services for running the backups should run on any systemd based host.  If you're using a host that is using SysV/BSD init script system then you will have to create scripts by adapting the systemd service files and schedule them with cron.  

##### *NOTE:* All docker activity in these various services and Dockerfiles is run from `/home/core`.  This is the default user on CoreOS instances.  If you're using another Linux based host (or whatever) you'll have to make adjustments to the config files I have here in this repo to account for the home directory you're using or where you might be running docker.

Steps
-----

* **Backup Present Nessus Install**: Create a tarball of the license or configuration being used currently. (if needed)

* **Create Docker Nessus Image**: Copy Dockerfile to Docker host and generate the image
 
* **Create Docker Nessus Container**: Run Docker Nessus image to create container
 
* **Configure Backup**: (OPTIONAL) Copy provided systemd service files to CoreOS host to enable scheduled backup
 
### Backup Present Nessus Install

  * Run backup command found [here](https://gist.github.com/jcwx/a0e3199ad42fee393dae) on present Nessus installation
  * Retrieve the MAC address of the host where Nessus is running. (this MAC is needed in order to restore the configuration with the presently used license in a Docker container)

### Create Docker Nessus Image

  * copy nessus.tgz tarball to docker host
  * copy Nessus rpm to docker host
  * rename the rpm file name in the Dockerfile to represent the rpm you are using
  * copy Dockerfile from this repo to your Docker host
  * review comments and alter Dockerfile to suit your needs
  * `docker build -t nessus .`

### Create Docker Nessus Container

  * use the MAC from the backup process mentioned earlier
  * `docker run -p 8834:8834 --mac-address F4:CE:46:7E:71:B0 --name=nessus -d nessus`
  * use docker command to manage the container (`docker restart <container>` for instance)

### *OR* Create Systemd Nessus Service

  * copy `nessus.service` to `/etc/systemd/system`
  * edit `nessus.service` and replace the MAC on line #12 with MAC address from the backup process mentioned earlier (if needed), otherwise delete line #12
  * run `systemctl daemon-reload && systemctl start nessus`
 
The docker container can now be managed by the systemd service.  You can start, restart, get status or whatever is available with the `systemctl` command.  The docker service will also start at boot and be shut down properly when the host system is cycled.  
 
You can now log into your running Nessus instance at:

https://(your-host-ip):8834

### _(OPTIONAL)_ Create Local Host Backup Service

This service writes a gzip compressed tarball file locally.

  * (as root) copy `backup-nessus.service` and `backup-nessus.timer` to `/etc/systemd/system` directory
  * run `systemctl daemon-reload && systemctl start backup-nessus.service` (should generate a nessus.tgz backup in '/home/core' or wherever you're running docker)
  * run `systemctl start backup-nessus.timer` (is configured to run every hour)
  * edit line #8 to adjust backup cycle 
  * run `systemctl daemon-reload && systemctl restart backup-nessus-s3.service`

### _(OPTIONAL)_ Create Amazon S3 Backup Service

This service writes a gzip compressed tarball file locally, then copies it to Amazon S3 with the gof3r command.

  * retrieve the gof3r binary from https://github.com/rlmcpherson/s3gof3r
  * (as root) copy `backup-nessus-s3.service` and `backup-nessus-s3.timer` to `/etc/systemd/system` directory
  * populate the environment keys in `backup-nessus-s3.service` with your Amazon S3 keys (lines #5 & #6)
  * change the destination bucket on line #28 (see the `-b` flag) to reflect the bucket name you have at Amazon S3 for this task -- you will replace `nessus-bak` with your bucket name
  * the tarball written in S3 will be named `nessus-s3_<date>.tgz`
  * run `systemctl start backup-nessus-s3.timer` (is configured to run every hour)
  * edit line #8 to adjust backup cycle 
  * run `systemctl daemon-reload && systemctl restart backup-nessus-s3.service`

### _(OPTIONAL)_ Create Docker Image from Amazon S3 Backup

This process will create a new Docker image from a backup stored on Amazon S3.

  * copy Nessus rpm to docker host
  * copy Dockerfile.Amazon_S3 to your docker host
  * rename Dockerfile.Amazon_S3 to Dockerfile
  * get gof3r binary from https://github.com/rlmcpherson/s3gof3r, place in local docker directory
  * rename the rpm file name in the Dockerfile to represent the rpm you are using
  * populate the environment keys with your Amazon S3 keys (lines #33 & #34)
  * change the destination bucket on line #39 (see the `-b` flag) to reflect the bucket name you have at Amazon S3 for this task -- you will replace `nessus-bak` with your bucket name
  * review other comments and alter Dockerfile to suit your needs
  * `docker build -t nessus .`

 
