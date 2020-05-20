#!/bin/bash

rm -rf /tmp/data.sql

function create_db_schema() {
    mysql -h ${MYSQL_MASTER_HOST} \
        --user="${MYSQL_USER}" \
        --password="${MYSQL_PASSWORD}" \
        --database="${MYSQL_DATABASE}" < /opt/scripts/database-schema.sql
}

function populate_data1() {
    echo "Populating first 1000 records"
    for x in $(seq 1 1000); do
        NAME=$(head /dev/urandom  | base64 | head -n1 | cut -b -32)
        ADDRESS=$(head /dev/urandom  | base64 | head -n1 | cut -b -100)
        echo "insert into foo(name, address) values('DATA1--${NAME}', '${ADDRESS}');" >> /tmp/data.sql
    done
    mysql -h ${MYSQL_MASTER_HOST} \
        --user="${MYSQL_USER}" \
        --password="${MYSQL_PASSWORD}" \
        --database="${MYSQL_DATABASE}" < /tmp/data.sql
}

function populate_data2() {
    echo "Populating next 300 records with other data"
    echo "To check replication"
    for x in $(seq 1 300); do
        NAME=$(head /dev/urandom  | base64 | head -n1 | cut -b -32)
        ADDRESS=$(head /dev/urandom  | base64 | head -n1 | cut -b -100)
        echo "insert into foo(name, address) values('DATA2--${NAME}', '${ADDRESS}');" >> /tmp/data.sql
    done
    mysql -h ${MYSQL_MASTER_HOST} \
        --user="${MYSQL_USER}" \
        --password="${MYSQL_PASSWORD}" \
        --database="${MYSQL_DATABASE}" < /tmp/data.sql
}

function get_replication_data() {
    echo "Locking tables"
    mysql -h ${MYSQL_MASTER_HOST} \
        --user="root" \
        --password="${MYSQL_ROOT_PASSWORD}" \
        --database="${MYSQL_DATABASE}" <<< "use ${MYSQL_DATABASE}; FLUSH TABLES WITH READ LOCK;"

    echo
    echo "Get master status..."
    mysql -h ${MYSQL_MASTER_HOST} \
        --user="root" \
        --password="${MYSQL_ROOT_PASSWORD}" \
        --database="${MYSQL_DATABASE}" <<< "use ${MYSQL_DATABASE}; SHOW MASTER STATUS\G;" > /opt/scripts/master-status.txt
    cat /opt/scripts/master-status.txt

    echo
    echo "Generating MySQL dump..."
    mysqldump -h ${MYSQL_MASTER_HOST} \
        --user="${MYSQL_USER}" \
        --password="${MYSQL_PASSWORD}" \
        --databases "${MYSQL_DATABASE}" > /opt/scripts/database-dump.sql

    echo
    echo "Unlocking tables"
    mysql -h ${MYSQL_MASTER_HOST} \
        --user="${MYSQL_USER}" \
        --password="${MYSQL_PASSWORD}" \
        --database="${MYSQL_DATABASE}" <<< "use ${MYSQL_DATABASE}; UNLOCK TABLES;"
}

function process_master_status() {
    echo "Processing Master status data..."
    export MASTER_LOG_POSITION=$(cat /opt/scripts/master-status.txt | tr -d ' ' | grep Position | cut -d':' -f2)
    export MASTER_LOG_FILE=$(cat /opt/scripts/master-status.txt | tr -d ' ' | grep File | cut -d':' -f2)
}

function replicate_data() {
    echo "Loading MySQL dump to replica node ${MYSQL_REPLICA1_HOST}..."
    mysql -h ${MYSQL_REPLICA1_HOST} \
        --user="${MYSQL_USER}" \
        --password="${MYSQL_PASSWORD}" \
        --database="${MYSQL_DATABASE}" < /opt/scripts/database-dump.sql

    echo "Loading MySQL dump to replica node ${MYSQL_REPLICA2_HOST}..."
    mysql -h ${MYSQL_REPLICA2_HOST} \
        --user="${MYSQL_USER}" \
        --password="${MYSQL_PASSWORD}" \
        --database="${MYSQL_DATABASE}" < /opt/scripts/database-dump.sql
}

function start_slave() {
    process_master_status

    slave_config="CHANGE MASTER TO MASTER_HOST='${MYSQL_MASTER_HOST}',MASTER_USER='${MYSQL_REPLICA_USER}', MASTER_PASSWORD='${MYSQL_REPLICA_PASSWORD}', MASTER_LOG_FILE='${MASTER_LOG_FILE}', MASTER_LOG_POS=${MASTER_LOG_POSITION}"

    echo "Replica configuration statement:"
    echo "${slave_config}"

    echo "Executing in ${MYSQL_REPLICA1_HOST}"
    mysql -h ${MYSQL_REPLICA1_HOST} \
        --user="root" \
        --password="${MYSQL_ROOT_PASSWORD}" \
        --database="${MYSQL_DATABASE}" <<< "${slave_config}; START SLAVE; SHOW SLAVE STATUS\G"

    echo "Executing in ${MYSQL_REPLICA2_HOST}"
    mysql -h ${MYSQL_REPLICA2_HOST} \
        --user="root" \
        --password="${MYSQL_ROOT_PASSWORD}" \
        --database="${MYSQL_DATABASE}" <<< "${slave_config}; START SLAVE; SHOW SLAVE STATUS\G"

}

echo "Executing $@..."
$@
