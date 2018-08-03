from postgres

ARG docker_release_path
ARG local_release_path

RUN apt-get update
RUN apt-get install unzip


COPY PostgreSQL/load_release-postgresql.sh ./scripts/load_release-postgresql.sh
COPY PostgreSQL/create-database-postgres.sql ./docker-entrypoint-initdb.d/create-database-postgres.sql
COPY PostgreSQL/environment-postgresql.sql ./docker-entrypoint-initdb.d/environment-postgresql.sql
COPY $local_release_path $docker_release_path
