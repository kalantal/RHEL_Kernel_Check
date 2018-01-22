#!/bin/bash
#set -x

#Change "to" and "from" where appropriate
#to=justin.restivo@citi.com
to=dl.cate.global.cate.auto.test.environment.owners@imceu.eu.ssmb.com
from=kernel-checker@citi.com
kernelcheck_log=/bin/kernel-check/kernelcheck_log
notrhel=/bin/kernel-check/not-rhel
available=/bin/kernel-check/available
notavailable=/bin/kernel-check/not-available

#Fresh start
echo > $kernelcheck_log
sed -i '1d' $kernelcheck_log

#Check to see if using RHEL
if [ ! -f /etc/redhat-release ]; then
        echo "System is not RHEL -- exiting."
        touch $notrhel
        echo "To: $to" >> $notrhel
        echo "From: $from" >> $notrhel
        echo "Subject: $(uname -n) is not a RHEL system" >> $notrhel
        sendmail $to < $notrhel
	sudo rm $notrhel
        exit 1
fi

#Sendmail dependancy
rpm -qa | grep -qw sendmail || sudo yum install sendmail

#rpm -qa | grep -qw lshw || sudo yum install lshw
#You could also add lshw to validate if the machine is virtual or physical
#This functionality is removed because this will be run from a baseline system
#Example that would be added as an echo to $kernelcheck_log
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
if [ -f $available ] && [ -s checker ] ; then
	rm $available
	rm checker
fi

#Remove the first check
#This is only done to make evaluating the status easier
#If "checker" is 0 bytes, there isn't any update information available inside it
sudo rm checker

#If we have already seen there is an update, exit
if [ -f $available ]; then
	echo "Kernel update available at $(date)"
	echo "Notification already dispatched to: $to"
	exit 1
fi

#Check for kernel updates available in YUM
if yum check-update | grep kernel | grep redhat-release
then
		echo "Kernel update available at $(date)" >> $kernelcheck_log
		echo >> $kernelcheck_log
		echo "Current version of RHEL kernel:" >> $kernelcheck_log
		cat /etc/redhat-release >> $kernelcheck_log
		uname -r >>$kernelcheck_log
		echo >> $kernelcheck_log
		echo "New version(s) of RHEL kernel:" >> $kernelcheck_log
		yum check-update | grep kernel | grep redhat-release >> $kernelcheck_log
		touch $available
		#Build sendmail configuration file
		echo "To: $to" >> $available
		echo "From: $from" >> $available
		echo "Subject: RHEL Kernel update available on system: $(uname -n)" >> $available
		echo >> $kernelcheck_log
		cat $kernelcheck_log >> $available
		sendmail $to < $available
		#Cleanup
		#sudo rm $available
else
		echo "No kernel update available at $(date)" >> $kernelcheck_log
		echo >> $kernelcheck_log
		echo "Current version of RHEL kernel:" >> $kernelcheck_log
		cat /etc/redhat-release >> $kernelcheck_log
		uname -r >>$kernelcheck_log
		echo >> $kernelcheck_log
		touch $notavailable
		#Build sendmail configuration file
		echo "To: $to" >> $notavailable
		echo "From: $from" >> $notavailable
		echo "Subject: No RHEL kernel update available on system: $(uname -n)" >> $notavailable
		echo >> $kernelcheck_log
		cat $kernelcheck_log >> $notavailable
		#sendmail $to < $notavailable
		#Cleanup
		sudo rm $notavailable
fi

cat $kernelcheck_log

exit 0
