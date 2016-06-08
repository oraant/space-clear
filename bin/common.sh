#!/bin/bash

# author: oraant
# create: 2016-06-04
# update: 2016-06-04

# get config files
export PATH=$PATH:/usr/bin:/usr/sbin:/sbin:/bin:.
SC_HOME=$(cd $(dirname $0)/..;/bin/pwd)
global_cfg=$SC_HOME/conf/global.cfg
delete_cfg=$SC_HOME/conf/delete.cfg
black_cfg=$SC_HOME/conf/black.cfg
disk_cfg=$SC_HOME/conf/disk.cfg

# make sure the config files are exists and read permission is granted
function verify_config()
{
    for config_file in $global_cfg $delete_cfg $black_cfg $disk_cfg
    do
        if ! [ -f $config_file ]
        then
            echo 'ERROR:'
            echo '  Configure file does not not exist.'
            echo '  Please check the file:' $config_file
            echo ''
            exit 1
        fi
    done
}

# let the global config file take effect.
function configure_global()
{
    source $global_cfg &>/dev/null
    if (( $? != 0 ))
    then
        echo 'ERROR:'
        echo '  Global Configure file can not parse.'
        echo '  Please check the file like this: "bash' $global_cfg '"'
        echo ''
        exit 2
    fi
}

function check_user()
{
    (( ${#user[@]} == 0 )) && configure_global
    if (( ${#user[@]} == 0 ))
    then
        echo 'ERROR:'
        echo '  Did not configure which user can execute this script.'
        echo '  Please check the user configuration in:' $global_cfg
        echo ''
        exit 2
    fi

    oper=$(whoami)
    if [[ " ${user[@]} " =~ " $oper " ]]
    then
        return 0
    else
        echo 'ERROR:'
        echo '  The user you are using can not execute this script'
        echo '  Please check the user configuration in:' $global_cfg
        echo ''
        exit 3
    fi
}

### lib for logs start ###

function debug()
{
    [[ $loglevel -ge 5 ]] || return
    echo -e $(date +%Y-%m-%d' '%H:%M:%S)' DEBUG: '$* >> $logfile
}

function log()
{
    [[ $loglevel -ge 4 ]] || return
    echo -e $(date +%Y-%m-%d' '%H:%M:%S)'   LOG: '$* >> $logfile
}

function alert()
{
    [[ $loglevel -ge 3 ]] || return
    echo -e $(date +%Y-%m-%d' '%H:%M:%S)' ALERT: '$* >> $logfile
}

function warn()
{
    [[ $loglevel -ge 2 ]] || return
    echo -e $(date +%Y-%m-%d' '%H:%M:%S)'  WARN: '$* >> $logfile
}

function error()
{
    [[ $loglevel -ge 1 ]] || return
    echo -e $(date +%Y-%m-%d' '%H:%M:%S)' ERROR: '$* >> $logfile
}

### lib for logs end ###
