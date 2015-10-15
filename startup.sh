#!/bin/sh

# check if previous install is on persistent
# drive, if not, copy new install to 
# persistent drive
if [ ! -d /opt/nessus-persist/var ]; then
	if [ ! -d /opt/nessus-persist ]; then
		/bin/mkdir /opt/nessus-persist
	fi
    /bin/mv /opt/nessus/* /opt/nessus-persist/
fi

# cp backup data from previous install into new
if [ -d /tmp/opt ]; then
    /bin/cp -rf /tmp/opt/nessus-persist/* /opt/nessus-persist/
fi

# rm nessus directory if previous install exists
if [ -d /opt/nessus ]; then
    /bin/rm -rf /opt/nessus
fi

/bin/ln -s /opt/nessus-persist /opt/nessus
/opt/nessus/sbin/nessus-service -D
