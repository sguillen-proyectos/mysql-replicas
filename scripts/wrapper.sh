#!/bin/bash

function usage() {
    echo "$0 <master|slave|shell>"
}

function start_mysql() {
    # Wrapper to the original MySQL entrypoint
    exec /usr/local/bin/docker-entrypoint.sh mysqld
}
nn
function start_master() {
    echo "Starting MySQL master"
    start_mysql
}

function start_slave() {
    echo "Starting MySQL slave"
    start_mysql
}

command=${1:-master}
case $command in
    master)
        start_master
        ;;
    slave)
        start_slave
        ;;
    shell)
        bash
        ;;
    *)
        usage
        exit 1
esac
