#!/bin/bash

kernelcheck_log=/monitoring/alerts/kernelcheck_log
available=/monitoring/alerts/available
checker=/monitoring/alerts/checker
to=justin.restivo@citi.com

touch "$kernelcheck_log"
echo > $kernelcheck_log
sed -i '1d' $kernelcheck_log

cd /auto/bin/ || exit 1

#Make a file that knows if there's an update
#This is done to see if we have already run through the script before
#This prevents multiple alerts
sudo yum check-update | grep kernel > $checker

#If an update has already been seen and there is currently an update, remove the blockers
if [ -f $available ] && [ ! -s $checker ] ; then
        sudo rm $available
        sudo rm $checker
fi

if [ -f $available ]; then
        cat $available
        echo "Notification already sent"
        exit 0
fi

#Check for kernel updates available in YUM
if [ -f $kernelcheck_log ]
then
	echo "Kernel update in Artifactory available at $(date)" >> $kernelcheck_log
	echo >> $kernelcheck_log
	echo -en "Current version of RHEL:\\n" >> $kernelcheck_log
	echo -en "$(cat /etc/redhat-release)"	>> $kernelcheck_log
	echo -en "\\n\\nCurrent kernel on $(uname -n):\\n" >> $kernelcheck_log
	echo -en "$(uname -r)" >>$kernelcheck_log
	echo -en "\\n\\nNew version(s) of RHEL kernel in Artifactory:\\n" >> $kernelcheck_log
	sudo yum check-update | grep kernel >> $kernelcheck_log
	touch $available
	echo > $available
	sed -i '1d' $available
	echo >> $kernelcheck_log
	cat $kernelcheck_log >> $available
	mail -s "Kernel update available for $(uname -n)" $to < $available
	#sudo rm $available
fi

cat $kernelcheck_log
sudo rm $kernelcheck_log

exit 0
