# kernel-check

This is a self-contained script to check for a kernel or RHEL update from a baseline system. This script will notify you once that a new update is ready. It will shut off after a notification and file signaling this are created. A file named "available" will also be present to be used as a trigger for using this information. Once the kernel or version has been updated, it will turn back on and begin notifying you of new releases. 

Setup:

    sudo mkdir -p /bin/kernel-check
    sudo cp kernelcheck.sh /bin/kernel-check/kernelcheck.sh
    sudo chmod +x /bin/kernel-check/kernelcheck.sh
    #Edit "to" field
    vi /bin/kernel-check/kernelcheck.sh
    crontab –e
    #2:00 am daily run example:
    #RHEL Kernel Check -- see /bin/kernel-check for more info
    0 2 * * * /bin/kernel-check/kernelcheck.sh

Example output:

    To: justinjrestivo@gmail.com
    From: root@localhost
    Subject: RHEL Kernel update available on system: localhost

    Kernel update available at Wed Jan 17 22:38:53 CST 2018

    Current version of RHEL kernel:
    Red Hat Enterprise Linux Server release 7.4 (Maipo)
    3.10.0-693.11.1.el7.x86_64

    New version(s) of RHEL kernel:
    kernel.x86_64                    3.10.0-693.11.6.el7          rhel-7-server-rpms
    kernel-devel.x86_64              3.10.0-693.11.6.el7          rhel-7-server-rpms
    kernel-headers.x86_64            3.10.0-693.11.6.el7          rhel-7-server-rpms
    kernel-tools.x86_64              3.10.0-693.11.6.el7          rhel-7-server-rpms
    kernel-tools-libs.x86_64         3.10.0-693.11.6.el7          rhel-7-server-rpms
