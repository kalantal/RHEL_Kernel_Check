#!/bin/bash

from=justin.restivo@citi.com
to=justin.restivo@citi.com
req=lshw
kernel_log=/tmp/kernel_log

echo > $kernel_log
sed -i '1d' $kernel_log

if [ ! -f /etc/redhat-release ]; then
    echo "System is not RHEL, exiting."
    exit 1
elif [ -f /etc/redhat-release ] ; then
    for package in $req; do
        if [ "$(rpm -qa $package 2>/dev/null)" == "" ]; then
            missing="${missing:+$missing }$package"
        fi
    done
    if [ -n "$missing" ]; then
        echo "$0: missing required RPM packages. Installing via sudo." 1>&2
        sudo yum -y install "$missing"
    fi
fi

cd "$(dirname "$0")"

if yum check-update | grep kernel
then
	echo "Kernel update available at $(date)" 2>&1 | tee -a $kernel_log
	echo >> $kernel_log
	lshw -class system 2>&1 -a $kernel_log | head -n 8
	touch available
	echo "To: $to" >> not-available
	echo "From: $from" >> available
	echo "Subject: RHEL Kernel update available" >> available
	cat $kernel_log >> available
	sendmail justin.restivo@citi.com < available
	rm available
else
	echo "No kernel update available at $(date)" 2>&1 | tee -a $kernel_log
	echo >> $kernel_log
	lshw -class system 2>&1 -a $kernel_log | head -n 8
	touch not-available
	echo "To: $to" >> not-available
	echo "From: $from" >> not-available
	echo "Subject: RHEL Kernel not update available" >> not-available
	cat $kernel_log >> not-available
	sendmail justin.restivo@citi.com < not-available
	rm not-available
fi

exit 0
