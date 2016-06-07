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
#  tmp_disk_stat=$SC_HOME/tmp/disk.tmp
#  tmp_calc_conf=$SC_HOME/tmp/disk.cfg
#  tmp_lock_file=$SC_HOME/tmp/disk.lck

# verify black.cfg
function verify_black_config()
{
    cat $black_cfg |egrep -v '^$|^#' |while read directory
    do
        if [ ! -d $directory ] && [ ! -f $directory ]
        then
            error "${directory} in Black Configure file can not parse."
            error "Please check the ${directory} in the configure file: ${black_cfg}"
            exit 5
        fi
    done
}

# verify delete.cfg 
function verify_delete_config()
{
    cat $delete_cfg |egrep -v '^$|^#' |while read time act files
    do
        if [[ ! $time =~ ^[0-9]+[m|h|d]$ ]]
        then
            error "${time} in Delete Configure file can not parse."
            error "Please check the time of ${files} in the configure file: ${delete_cfg}"
            exit 5
        fi

        if [[ $act != 'delete' ]] && [[ $act != 'clear' ]]
        then
            error "${act} in Delete Configure file can not parse."
            error "Please check the action of ${files} in the configure file: ${delete_cfg}"
            exit 5
        fi

        ls $files &>/dev/null
        if [[ $? != 0 ]]
        then
            error "${files} in Delete Configure file can not parse."
            error "Please check the files pattern of ${files} in the configure file: ${delete_cfg}"
            exit 5
        fi
    done
}

# filter files and delete it.
function filter_and_delete()
{
    cat $delete_cfg |egrep -v '^$|^#' |while read time act files
    do
        /bin/pwd
    done
}

verify_black_config
verify_delete_config
filter_and_delete
