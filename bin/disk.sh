#!/bin/bash

# author: oraant
# create: 2016-06-04
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
tmp_calc_cfg=$SC_HOME/tmp/disk.cfg
tmp_lock_file=$SC_HOME/tmp/disk.lck

# get disk configurations
function verify_disk_config()
{
    cat $disk_cfg |egrep -v '^$|^#' |while read part avail util
    do
        if [[ $avail =~ ^[0-9]+[G|M|K]$ ]] && [[ $util =~ ^[0-9]+%$ ]]
        then
            echo -n
        else
            error "Disk Configure file can not parse."
            error "Please check the ${part} partition in the configure file: \$SC_HOME/conf/disk.cfg"
            exit 5
        fi
    done
}

# transform unit in the configure file
function create_calc_file()
{
    cat $disk_cfg |egrep -v '^$|^#' |while read part avail util
    do
        avail_value=$(echo $avail|tr -d 'GMK')
        avail_unit=${avail: -1}
        new_util=$(echo $util|tr -d '%')
        case $avail_unit in
            'G')new_avail=$[avail_value*1024*1024];;
            'M')new_avail=$[avail_value*1024];;
            'K')new_avail=${value};;
        esac

        echo $part $new_avail $new_util >> $tmp_calc_cfg
    done

    if ! [ -f $tmp_calc_cfg ]
    then
        error 'Temp file create failed when transform unit.'
        error 'Please check the file and directory permission.'
        exit 5
    fi
}

# get disk status
function create_status_file()
{
    df -k |tail -n +2 |awk '{print $NF,$4,$5}' |tr -d '%' > $tmp_disk_stat

    # make sure files are exist
    if ! [ -f $tmp_disk_stat ]
    then
        error 'Temp file create failed when get disk status.'
        error 'Please check the file and directory permission.'
        exit 5
    fi
}

# judge if disk need warn according to configurations.
function disk_need_warn()
{
    cat $tmp_calc_cfg |while read part avail util
    do
        read now_part now_avail now_util < <(cat $tmp_disk_stat |awk -v p="$part" '{if($1==p){print}}')

        if [[ $now_avail -le $avail ]]
        then
            alert "available size of partition: ${part} is ${now_avail}KB,less than ${avail}KB"
            touch $tmp_lock_file
        fi

        if [[ $now_util -ge $util ]]
        then
            alert "utilization of partition: ${part} is ${now_util}%,over than ${util}%"
            touch $tmp_lock_file
        fi
    done

    if [ -f $tmp_lock_file ]
    then
        return 0
    else
        return 1
    fi
}

function clear_disk_tmp()
{
    [ -f $tmp_calc_cfg ] && rm $tmp_calc_cfg
    [ -f $tmp_disk_stat ] && rm $tmp_disk_stat
    [ -f $tmp_lock_file ] && rm $tmp_lock_file
}

function main()
{
    verify_disk_config \
    && create_calc_file \
    && create_status_file \
    && disk_need_warn
    need=$?
    
    clear_disk_tmp

    return $need
}

main
