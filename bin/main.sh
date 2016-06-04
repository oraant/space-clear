#!/bin/bash

# author: oraant
# create: 2016-06-04
# update: 2016-06-04

# load common shell
source $(dirname $0)/common.sh

# get global configuration
configure_global

# veryfi user
check_user

# verify arguments
# nothing to do.

# init environment
export PATH=$PATH:/usr/bin:/usr/sbin:/sbin:/bin:.
