#!/bin/sh
#
# This checks to see if there is an existing nessus
# install in the data container.  If there is not a 
# directory named /opt/nessus-persist/nessus/var
# (thus indicating the data container is new as well)
# the fresh install of Nessus on the newly created
# container is copied to the data container and
# the original install location is deleted.  Nessus
# is now solely installed on the data container
#
# The second part of the script is executed, where 
# the data container directory is soft linked to the
# standard install location on the new container.
# 
# 
if [ ! -f /opt/nessus-persist/nessus/var ]; then
    /bin/cp -a /opt/nessus /opt/nessus-persist
    /bin/rm -rf /opt/nessus
fi

/bin/ln -s /opt/nessus-persist/nessus /opt/nessus
/opt/nessus/sbin/nessusd
