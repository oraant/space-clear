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
tmp_remove_conf=$SC_HOME/tmp/delete.cfg
tmp_clear_conf=$SC_HOME/tmp/clear.cfg

# verify black.cfg
function verify_black_config()
{
    cat $black_cfg |egrep -v '^$|^#' |while read directory
    do
        if [ ! -d $directory ]
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

        if [[ $act != 'remove' ]] && [[ $act != 'clear' ]]
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
function filter_configure_file()
{
    cat $delete_cfg |egrep -v '^$|^#' |while read time act files
    do
        cat $black_cfg |egrep -v '^$|^#' |while read directory
        do
            for file in $files #in case of `ll dir*/file*.sh`
            do
                filepath=$(dirname $(readlink -f $file))
                echo $filepath $directory
                if [[ $filepath == $directory ]];then
                    echo 'match'
                    debug "$file has filtered by $directory in the configure file: $black_cfg."
                elif [[ $act == 'delete' ]];then
                    echo "$time $file">>$tmp_remove_conf
                    debug "$file will be removed"
                elif [[ $act == 'clear' ]];then
                    echo "$time $file">>$tmp_clear_conf
                    debug "$file will be cleared"
                fi
            done
        done
    done
}

function clear_tmp_file()
{
    [ -f $tmp_remove_conf ] && rm $tmp_remove_conf
    [ -f $tmp_clear_conf ] && rm $tmp_clear_conf
}

verify_black_config
verify_delete_config
filter_configure_file
#clear_tmp_file
