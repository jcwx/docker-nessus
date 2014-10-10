#!/bin/sh

if [ ! -f /opt/nessus-persist/nessus/var ]; then
    /bin/cp -a /opt/nessus /opt/nessus-persist
    /bin/rm -rf /opt/nessus
fi

/bin/ln -s /opt/nessus-persist/nessus /opt/nessus
/opt/nessus/sbin/nessusd
