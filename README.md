# artifactory-kernel-check

This is a self-contained script to check for a kernel or RHEL update from a baseline system. This script will notify you once that a new update is ready. It will shut off after a notification and file signaling this are created. A file named "available" will also be present to be used as a trigger for using this information. Once the kernel or version has been updated, it will turn back on and begin notifying you of new releases. 

Setup:

    git clone https://github.com/kalantal/artifactory-kernel-check.git
    cd artifactory-kernel-check/
    sudo mkdir -p /auto/bin/
    sudo cp artifactory-kernel-check.sh /auto/bin/artifactory-kernel-check.sh
    sudo chmod +x /auto/bin/artifactory-kernel-check.sh
    #Edit "to" field
    vi /bin/artifactory-kernel-check.sh
    crontab –e
    #2:00 am daily run example:
    #RHEL Kernel Check -- see /auto/bin/artifactory-kernel-check.sh for more info
    0 2 * * * /auto/bin/artifactory-kernel-check.sh

Example output:

    Kernel update in Artifactory available at Tue Feb  6 15:14:37 EST 2018

    Current version of RHEL:
    Red Hat Enterprise Linux Server release 7.4 (Maipo)

    Current kernel on vdimwmonitoring03.nam.nsroot.net:
    3.10.0-693.11.6.el7.x86_64

    New version(s) of RHEL kernel in Artifactory:
    kernel.x86_64                        3.10.0-693.17.1.el7           NOT-CERTIFIED
    kernel-headers.x86_64                3.10.0-693.17.1.el7           NOT-CERTIFIED
    kernel-tools.x86_64                  3.10.0-693.17.1.el7           NOT-CERTIFIED
    kernel-tools-libs.x86_64             3.10.0-693.17.1.el7           NOT-CERTIFIED
