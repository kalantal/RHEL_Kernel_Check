#!/bin/bash

#Change to & from where appropriate
from=justin.restivo@citi.com
to=justin.restivo@citi.com
kernel_log=/tmp/kernel_log

#Fresh start
echo > $kernel_log
sed -i '1d' $kernel_log

#Validate RHEL release
if [ ! -f /etc/redhat-release ]; then
    echo "System is not RHEL -- exiting."
    exit 1
fi

#Sendmail dependancy
rpm -qa | grep -qw sendmail || yum install sendmail

#Change directory to the current working directory
#This script is self contained and will clean up after itself
cd "$(dirname "$0")"

#Check for kernel updates available in YUM
if yum check-update | grep kernel
then
        echo "Kernel update available at $(date)" 2>&1 | tee -a $kernel_log
        echo >> $kernel_log
		echo "Current version of RHEL:" >> $kernel_log
		echo `cat /etc/redhat-release` >> $kernel_log
		echo `uname -rm` >>$kernel_log
		echo >> $kernel_log
        touch available
		#Build sendmail configuration file
        echo "To: $to" >> not-available
        echo "From: $from" >> available
        echo "Subject: RHEL Kernel update available" >> available
        echo >> $kernel_log
        cat $kernel_log >> available
        sendmail justin.restivo@citi.com < available
		#Cleanup
        rm available
else
        echo "No kernel update available at $(date)" 2>&1 | tee -a $kernel_log
        echo >> $kernel_log
		echo "Current version of RHEL:" >> $kernel_log
		echo `cat /etc/redhat-release` >> $kernel_log
		echo `uname -rm` >>$kernel_log
        echo >> $kernel_log		
        touch not-available
		#Build sendmail configuration file
        echo "To: $to" >> not-available
        echo "From: $from" >> not-available
        echo "Subject: RHEL Kernel not update available" >> not-available
        echo >> $kernel_log
        cat $kernel_log >> not-available
        sendmail justin.restivo@citi.com < not-available
		#Cleanup
        rm not-available
fi

exit 0
