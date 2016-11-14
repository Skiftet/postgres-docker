#!/bin/bash
set -e

RANDOM_PASSWORD=$(cat /dev/urandom | tr -dc A-Za-z0-9 | fold -w 16 | head -n 1)

psql -q -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
    CREATE USER $1 WITH PASSWORD '$RANDOM_PASSWORD';
    CREATE DATABASE $1;
    GRANT ALL PRIVILEGES ON DATABASE $1 TO $1;
EOSQL

echo $RANDOM_PASSWORD
