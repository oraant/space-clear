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
tmp_remove_cfg=$SC_HOME/tmp/delete.cfg
tmp_clear_cfg=$SC_HOME/tmp/clear.cfg

total_files=0
removed_files=0
cleared_files=0
blacked_files=0
too_new_files=0

# verify black.cfg
function verify_black_config()
{
    cat $black_cfg |egrep -v '^$|^#' |while read directory
    do
        if [ ! -d $directory ]
        then
            error "${directory} in Black Configure file can not parse."
            error "Please check the ${directory} in the configure file: \$SC_HOME/conf/black.cfg"
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
            error "Please check the time of ${files} in the configure file: \$SC_HOME/conf/delete.cfg"
            exit 5
        fi

        if [[ $act != 'remove' ]] && [[ $act != 'clear' ]]
        then
            error "${act} in Delete Configure file can not parse."
            error "Please check the action of ${files} in the configure file: \$SC_HOME/conf/delete.cfg"
            exit 5
        fi

        ls $files &>/dev/null
        if [[ $? != 0 ]]
        then
            error "${files} in Delete Configure file can not parse."
            error "Please check the files pattern of ${files} in the configure file: \$SC_HOME/conf/delete.cfg"
            exit 5
        fi
    done
}

function time_to_second()
{
    time=$1
    unit=${time: -1}
    value=$(echo $time|tr -d 'mhd')
    case $unit in
        'm')echo $(( value*60 ));;
        'h')echo $(( value*60*60 ));;
        'd')echo $(( value*60*60*24 ));;
    esac
}

function file_mtime_gap()
{
    mtime=$(stat --printf=%Y $1)
    ntime=$(date +%s)
    echo $ntime-$mtime|bc
}

# filter files and delete it.
function filter_configure_file()
{
    dirs=($(cat $black_cfg |egrep -v '^$|^#'))
    while read time act files
    do
        for file in $files #in case of `ll dir*/file*.sh`
        do
            total_files=$(( total_files+1 ))
            file_gap=$(file_mtime_gap $file)
            conf_gap=$(time_to_second $time)
            if [[ $conf_gap -gt $file_gap ]];then
                too_new_files=$(( too_new_files+1 ))
                debug "the mtime gap of $file is $file_gap seconds,less than $time configured in: \$SC_HOME/conf/delete.cfg"
                continue
            fi

            filepath=$(dirname $(readlink -f $file))

            if [[ " ${dirs[@]} " =~ " $filepath " ]];then
                blacked_files=$(( blacked_files+1 ))
                debug "$file has been filtered by $filepath in the configure file: \$SC_HOME/conf/black.cfg"
            elif [[ $act == 'remove' ]];then
                removed_files=$(( removed_files+1 ))
                echo $file>>$tmp_remove_cfg
                debug "$file will be removed"
            elif [[ $act == 'clear' ]];then
                cleared_files=$(( cleared_files+1 ))
                echo $file>>$tmp_clear_cfg
                debug "$file will be cleared"
            fi
        done
    done < <(cat $delete_cfg |egrep -v '^$|^#')
    log "Total: $total_files\tToo New: $too_new_files\tBlacklist: $blacked_files\tRemoved: $removed_files\tCleared: $cleared_files"
}

function delete_files()
{
    if [ -f $tmp_remove_cfg ];then
        tmp_path_r=($(cat $tmp_remove_cfg))
        echo "rm ${tmp_path_r[@]}"
    fi

    if [ -f $tmp_clear_cfg ];then
        for tmp_path_c in $(<$tmp_clear_cfg);do
            echo "> $tmp_path_c"
        done
    fi
}

function clear_tmp_file()
{
    [ -f $tmp_remove_cfg ] && rm $tmp_remove_cfg
    [ -f $tmp_clear_cfg ] && rm $tmp_clear_cfg
}

function main()
{
    verify_black_config \
    && verify_delete_config \
    && filter_configure_file \
    && delete_files

    clear_tmp_file
}
main
