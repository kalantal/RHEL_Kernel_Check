#!/bin/bash
#set -x

#Change "to" and "from" where appropriate
to=justinjrestivo@gmail.com
from=kernel-checker@citi.com
kernel_log=/tmp/kernel_log

#Fresh start
echo > $kernel_log
sed -i '1d' $kernel_log

#If we have already seen that the system is not rhel AND the system is reporting to currently be RHEL, then remove the blocker saying it's not rhel.
if [ -f not-rhel ] && [ -f /etc/redhat-release ] ; then
	rm not-rhel
fi

#If already seen to be not rhel, exit
if [ -f not-rhel ]; then
	echo "System is not RHEL -- exiting."
	echo "Notification already dispatched to: $to"
	exit 1
fi

#Check to see if not rhel
if [ ! -f /etc/redhat-release ]; then
        echo "System is not RHEL -- exiting."
        touch not-rhel
        echo "To: $to" >> not-rhel
        echo "From: $from" >> not-rhel
        echo "Subject: `uname -n` is not a RHEL system" >> not-rhel
        sendmail $to < not-rhel
		#rm not-rhel
        exit 1
fi

#Sendmail dependancy
rpm -qa | grep -qw sendmail || sudo yum install sendmail

#You could also add lshw to validate if the machine is virtual or physical
#This functionality is removed because this will be run from a baseline system
#Example that would be added as an echo to $kernel_log
#sudo lshw | head -n 10

#Change directory to the current working directory
#This script is self contained and will clean up after itself
cd "$(dirname "$0")"

#Make a file that knows if there's an update
yum check-update | grep kernel | grep redhat-release > checker

#If an update has already been seen and there is currently an update, remove the blockers
if [ -f available ] && [ -s checker ] ; then
	rm available
	rm checker
fi

#remove the first check
rm checker

#If we have already seen there is an update, exit
if [ -f available ]; then
	echo "Kernel update available at $(date)"
	echo "Notification already dispatched to: $to"
	exit 1
fi

#Check for kernel updates available in YUM
if yum check-update | grep kernel | grep redhat-release
then
		echo "Kernel update available at $(date)" 2>&1 | tee -a $kernel_log
		echo >> $kernel_log
		echo "Current version of RHEL kernel:" >> $kernel_log
		echo `cat /etc/redhat-release` >> $kernel_log
		echo `uname -r` >>$kernel_log
		echo >> $kernel_log
		echo "New version(s) of RHEL kernel:" >> $kernel_log
		yum check-update | grep kernel | grep redhat-release >> $kernel_log
		touch available
		#Build sendmail configuration file
		echo "To: $to" >> available
		echo "From: $from" >> available
		echo "Subject: RHEL Kernel update available on system: `uname -n`" >> available
		echo >> $kernel_log
		cat $kernel_log >> available
		sendmail $to < available
		#Cleanup
		#rm available
else
		echo "No kernel update available at $(date)" 2>&1 | tee -a $kernel_log
		echo >> $kernel_log
		echo "Current version of RHEL kernel:" >> $kernel_log
		echo `cat /etc/redhat-release` >> $kernel_log
		echo `uname -r` >>$kernel_log
		echo >> $kernel_log		
		touch not-available
		#Build sendmail configuration file
		echo "To: $to" >> not-available
		echo "From: $from" >> not-available
		echo "Subject: No RHEL kernel update available on system: `uname -n`" >> not-available
		echo >> $kernel_log
		cat $kernel_log >> not-available
		#sendmail $to < not-available
		#Cleanup
		rm not-available
fi

cat $kernel_log

exit 0
