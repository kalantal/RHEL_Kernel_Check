
#!/bin/bash
#set -x

#Change "to" and "from" where appropriate
to=justin.restivo@citi.com
#to=dl.cate.global.cate.auto.test.environment.owners@imceu.eu.ssmb.com
from=kernel-checker@citi.com
kernelcheck_log=/auto/bin/kernel-check/kernelcheck_log
notrhel=/auto/bin/kernel-check/not-rhel
available=/auto/bin/kernel-check/available
notavailable=/auto/bin/kernel-check/not-available
checker=/auto/bin/kernel-check/checker

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
sudo rpm -qa | grep -qw sendmail || sudo yum install sendmail -y

#rpm -qa | grep -qw lshw || sudo yum install lshw
#You could also add lshw to validate if the machine is virtual or physical
#This functionality is removed because this will be run from a baseline system
#Example that would be added as an echo to $kernelcheck_log
#sudo lshw | head -n 10

#Change directory to our running directory
sudo cd /bin/kernel-check

#Make a file that knows if there's an update
#This is done to see if we have already run through the script before
#A counter would not work because we need to be able to reset when the kernel is tested and updated
sudo yum check-update | grep kernel > $checker

#If an update has already been seen and there is currently an update, remove the blockers
if [ -f $available ] && [ ! -s checker ] ; then
        sudo rm $available
        sudo rm $checker
fi

#Remove the first check
#This is only done to make evaluating the status easier
#If "checker" is 0 bytes, there isn't any update information available inside it
#if [ -f $checker ]; then
#sudo rm checker
#fi

#If we have already seen there is an update, exit
if [ -f $available ]; then
        echo "Kernel update available at $(date)"
        echo "Notification already dispatched to: $to"
                cat $kernelcheck_log
                sudo rm kernelcheck_log
        exit 1
fi

#Check for kernel updates available in YUM
if sudo yum check-update | grep kernel
then
                echo "Kernel update available at $(date)" >> $kernelcheck_log
                echo >> $kernelcheck_log
                echo "Current version of RHEL kernel:" >> $kernelcheck_log
                cat /etc/redhat-release >> $kernelcheck_log
                uname -r >>$kernelcheck_log
                echo >> $kernelcheck_log
                echo "New version(s) of RHEL kernel:" >> $kernelcheck_log
                sudo yum check-update | grep kernel >> $kernelcheck_log
                touch $available
                echo > $available
                sed -i '1d' $available
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
                echo > $notavailable
                sed -i '1d' $notavailable
                #Build sendmail configuration file
                echo "To: $to" >> $notavailable
                echo "From: $from" >> $notavailable
                echo "Subject: No RHEL kernel update available on system: $(uname -n)" >> $notavailable
                echo >> $kernelcheck_log
                cat $kernelcheck_log >> $notavailable
                #sendmail $to < $notavailable
                #Cleanup
                #sudo rm $notavailable
fi

cat $kernelcheck_log
sudo rm kernelcheck_log

exit 0
