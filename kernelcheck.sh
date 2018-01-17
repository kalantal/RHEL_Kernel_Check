#!/bin/bash

from=justin.restivo@citi.com
to=justin.restivo@citi.com
kernel_log=/tmp/kernel_log

cd "$(dirname "$0")"

echo > $kernel_log

if yum check-update | grep kernel
then
	echo "Kernel update available at $(date)" 2>&1 | tee -a $kernel_log
	touch available
	echo "To: $to" >> not-available
	echo "From: $from" >> available
	echo "Subject: RHEL Kernel update available" >> available
	cat $kernel_log >> available
	sendmail justin.restivo@citi.com < available
	rm available
else
	echo "No kernel update available at $(date)" 2>&1 | tee -a $kernel_log
	touch not-available
	echo "To: $to" >> not-available
	echo "From: $from" >> not-available
	echo "Subject: RHEL Kernel not update available" >> not-available
	cat $kernel_log >> not-available
	sendmail justin.restivo@citi.com < not-available
	rm not-available
fi

exit 0
