
FROM postgres:9.6

ENV PGDATA /var/lib/postgresql/data/pgdata
ENV POSTGRES_USER postgres

RUN localedef -i sv_SE -c -f UTF-8 -A /usr/share/locale/locale.alias sv_SE.UTF-8
ENV LANG sv_SE.utf8

RUN apt-get update \
   && apt-get install -y python3-pip python3.4 lzop pv daemontools git postgresql-plpython-9.6 \
   && pip3 install wal-e[swift] python-swiftclient python-keystoneclient dumb-init \
   && apt-get remove -y git \
   && apt-get clean \
   && rm -rf /var/lib/apt/lists/*

COPY create-user.sh /create-user.sh
COPY entrypoint.sh /
COPY setup-wale.sh /docker-entrypoint-initdb.d/
RUN chmod +x /create-user.sh /entrypoint.sh /docker-entrypoint-initdb.d/setup-wale.sh

ENTRYPOINT ["dumb-init", "/entrypoint.sh"]

CMD ["postgres"]
