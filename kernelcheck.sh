#!/bin/bash

kernel_log=/tmp/kernel_log
cd "$(dirname "$0")"

echo > $kernel_log

if yum check-update | grep kernel
then
	echo "Kernel update available at $(date)" 2>&1 | tee -a $kernel_log
	touch available
	echo > available
	echo "From: root <justin@vdimwmonitoring03@nam.nsroot.net>" >> available
	echo "To: root <justin@vdimwmonitoring03@nam.nsroot.net>" >> available
	echo "Subject: RHEL Kernel update available" >> available
	cat $kernel_log >> available
	sendmail justin.restivo@citi.com < available
	rm available
else
	echo "No kernel update available at $(date)" 2>&1 | tee -a $kernel_log
	touch not-available
	echo > not-available
	echo "From: root <justin@vdimwmonitoring03@nam.nsroot.net>" >> not-available
	echo "To: root <justin@vdimwmonitoring03@nam.nsroot.net>" >> not-available
	echo "Subject: RHEL Kernel not update available" >> not-available
	cat $kernel_log >> not-available
	sendmail justin.restivo@citi.com < not-available
	rm not-available
fi

exit 0
