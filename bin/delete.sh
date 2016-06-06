#!/bin/bash

# author: oraant
# create: 2016-06-06
# update: 2016-06-06

# load common shell
source $(dirname $0)/common.sh

# get global configuration
configure_global

# veryfi user
check_user

# verify arguments
# nothing to do.

# init environment
#export PATH=$PATH:/usr/bin:/usr/sbin:/sbin:/bin:.
tmp_disk_stat=$SC_HOME/tmp/disk.tmp
tmp_calc_conf=$SC_HOME/tmp/disk.cfg
tmp_lock_file=$SC_HOME/tmp/disk.lck

# get disk configurations
function verify_black_config()
{
    cat $black_cfg |egrep -v '^$|^#' |while read directory
    do
        if [ -d $directory ] || [ -f $directory ]
        then
            echo -n ''
        else
            error "Disk Configure file can not parse."
            error "Please check the ${part} partition in the configure file: ${disk_cfg}"
            exit 5
        fi
    done
}
verify_black_config
