
FROM postgres:9.6

ENV PGDATA /var/lib/postgresql/data/pgdata
ENV POSTGRES_USER postgres

RUN localedef -i sv_SE -c -f UTF-8 -A /usr/share/locale/locale.alias sv_SE.UTF-8
ENV LANG sv_SE.utf8

COPY create-user.sh /create-user.sh
RUN chmod +x /create-user.sh
