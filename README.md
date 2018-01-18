# RHEL_Kernel_Check

This is a self contained script to check for a kernel update from a baseline system.

    cp kernelcheck.sh /etc/cron.daily/
    chmod +x /etc/cron.daily/kernelcheck.sh
    crontab –e
    #2:00 am daily run example:
    0 2 * * * ~/RHEL_Kernel_Check/kernelcheck.sh

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
