#!/bin/bash

# author: oraant
# create: 2016-06-04
# update: 2016-06-04

# get config files
SC_HOME=$(cd $(dirname $0)/..;pwd)
global_cfg=$SC_HOME/conf/global.conf
delete_cfg=$SC_HOME/conf/delete.conf
black_cfg=$SC_HOME/conf/black.conf
disk_cfg=$SC_HOME/conf/disk.conf

# make sure the config files are exists and read permission is granted
function verify_config()
{
    for config_file in $global_cfg $delete_cfg $black_cfg $disk_cfg
    do
        if ! [ -r $config_file ]
        then
            echo 'ERROR:'
            echo '  Configure file does not not exist or can not be read.'
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
