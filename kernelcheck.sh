#!/bin/bash
#set -x

#Change "to" and "from" where appropriate
to=justinjrestivo@gmail.com
from=kernel-checker@citi.com
kernel_log=/tmp/kernel_log

#Fresh start
echo > $kernel_log
sed -i '1d' $kernel_log

#Check to see if using RHEL
if [ ! -f /etc/redhat-release ]; then
        echo "System is not RHEL -- exiting."
        touch not-rhel
        echo "To: $to" >> not-rhel
        echo "From: $from" >> not-rhel
        echo "Subject: $(uname -n) is not a RHEL system" >> not-rhel
        sendmail $to < not-rhel
	sudo rm not-rhel
        exit 1
fi

#Sendmail dependancy
rpm -qa | grep -qw sendmail || sudo yum install sendmail

#rpm -qa | grep -qw lshw || sudo yum install lshw
#You could also add lshw to validate if the machine is virtual or physical
#This functionality is removed because this will be run from a baseline system
#Example that would be added as an echo to $kernel_log
#sudo lshw | head -n 10

#Change directory to the current working directory
#This script is self contained and will clean up after itself
#Since we are forced to work in cron, this is a good idea unless we change how this script is called
#Then we would change the setup to /bin/kernel-check or make a configurable RPM. Might not be worth the time investment
sudo cd "$(dirname "$0")" || exit 1

#Make a file that knows if there's an update
#This is done to see if we have already run through the script before
#A counter would not work because we need to be able to reset when the kernel is tested and updated
yum check-update | grep kernel | grep redhat-release > checker

#If an update has already been seen and there is currently an update, remove the blockers
if [ -f available ] && [ -s checker ] ; then
	rm available
	rm checker
fi

#Remove the first check
#This is only done to make evaluating the status easier
#If "checker" is 0 bytes, there isn't any update information available inside it
sudo rm checker

#If we have already seen there is an update, exit
if [ -f available ]; then
	echo "Kernel update available at $(date)"
	echo "Notification already dispatched to: $to"
	exit 1
fi

#Check for kernel updates available in YUM
if yum check-update | grep kernel | grep redhat-release
then
		echo "Kernel update available at $(date)" >> $kernel_log
		echo >> $kernel_log
		echo "Current version of RHEL kernel:" >> $kernel_log
		cat /etc/redhat-release >> $kernel_log
		uname -r >>$kernel_log
		echo >> $kernel_log
		echo "New version(s) of RHEL kernel:" >> $kernel_log
		yum check-update | grep kernel | grep redhat-release >> $kernel_log
		touch available
		#Build sendmail configuration file
		echo "To: $to" >> available
		echo "From: $from" >> available
		echo "Subject: RHEL Kernel update available on system: $(uname -n)" >> available
		echo >> $kernel_log
		cat $kernel_log >> available
		sendmail $to < available
		#Cleanup
		#sudo rm available
else
		echo "No kernel update available at $(date)" >> $kernel_log
		echo >> $kernel_log
		echo "Current version of RHEL kernel:" >> $kernel_log
		cat /etc/redhat-release >> $kernel_log
		uname -r >>$kernel_log
		echo >> $kernel_log
		touch not-available
		#Build sendmail configuration file
		echo "To: $to" >> not-available
		echo "From: $from" >> not-available
		echo "Subject: No RHEL kernel update available on system: $(uname -n)" >> not-available
		echo >> $kernel_log
		cat $kernel_log >> not-available
		#sendmail $to < not-available
		#Cleanup
		sudo rm not-available
fi

cat $kernel_log

exit 0
