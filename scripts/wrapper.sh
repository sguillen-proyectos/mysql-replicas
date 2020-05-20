#!/bin/bash

function usage() {
    echo "$0 <master|slave|shell>"
}

function start_mysql() {
    # Call the original MySQL entrypoint
    exec /usr/local/bin/docker-entrypoint.sh mysqld
}

function start_master() {
    echo "Starting MySQL master"
    envsubst < /opt/mysql/conf/master.cnf > /etc/mysql/conf.d/master.cnf
    envsubst < /opt/mysql/conf/sql/master-init.sql > /docker-entrypoint-initdb.d/master-init.sql
    start_mysql
}

function start_slave() {
    echo "Starting MySQL slave"
    envsubst < /opt/mysql/conf/slave.cnf > /etc/mysql/conf.d/slave.cnf
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
    *)
        usage
        exit 1
esac
