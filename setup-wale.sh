#!/bin/bash

# Assumption: the group is trusted to read secret information
umask u=rwx,g=rx,o=
mkdir -p /etc/wal-e.d/env

echo "$SWIFT_AUTH_VERSION" > /etc/wal-e.d/env/SWIFT_AUTH_VERSION
echo "$SWIFT_AUTH_URL" > /etc/wal-e.d/env/SWIFT_AUTHURL
echo "$SWIFT_DOMAIN_ID" > /etc/wal-e.d/env/SWIFT_DOMAIN_ID
echo "$SWIFT_USER" > /etc/wal-e.d/env/SWIFT_USER
echo "$SWIFT_PASSWORD" > /etc/wal-e.d/env/SWIFT_PASSWORD
echo "$SWIFT_REGION" > /etc/wal-e.d/env/SWIFT_REGION
echo "$SWIFT_TENANT_ID" > /etc/wal-e.d/env/SWIFT_TENANT_ID
echo "$SWIFT_USER_DOMAIN_ID" > /etc/wal-e.d/env/SWIFT_USER_DOMAIN_ID
echo "$SWIFT_USER_ID" > /etc/wal-e.d/env/SWIFT_USER_ID
echo "$WALE_SWIFT_PREFIX" > /etc/wal-e.d/env/WALE_SWIFT_PREFIX

chown -R root:postgres /etc/wal-e.d

echo "Authority: Master - Scheduling WAL backups";

if grep -q "/etc/wal-e.d/env" "$PGDATA/postgresql.conf"
then
    echo "wal-e already configured in $PGDATA/postgresql.conf"
else
    echo "wal_level = archive" >> $PGDATA/postgresql.conf
    echo "archive_mode = on" >> $PGDATA/postgresql.conf
    echo "archive_command = 'envdir /etc/wal-e.d/env /usr/local/bin/wal-e wal-push %p'" >> $PGDATA/postgresql.conf
    echo "archive_timeout = 60" >> $PGDATA/postgresql.conf
fi

su - postgres -c "crontab -r || true"
su - postgres -c "crontab -l | { cat; echo \"0 3 * * * /usr/bin/envdir /etc/wal-e.d/env /usr/local/bin/wal-e backup-push $PGDATA\"; } | crontab -"
su - postgres -c "crontab -l | { cat; echo \"0 4 * * * /usr/bin/envdir /etc/wal-e.d/env /usr/local/bin/wal-e delete --confirm retain 7\"; } | crontab -"
