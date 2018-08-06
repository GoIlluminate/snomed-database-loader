from postgres

ARG docker_release_path
ARG local_release_path

RUN apt-get update
RUN apt-get install unzip
# Use dos2unix to change Windows line endings to Unix line endings
RUN apt-get update && apt-get install -y dos2unix


COPY PostgreSQL/load_release-postgresql.sh ./scripts/load_release-postgresql.sh
RUN dos2unix ./scripts/load_release-postgresql.sh

COPY PostgreSQL/create-database-postgres.sql ./scripts/create-database-postgres.sql
RUN dos2unix ./scripts/create-database-postgres.sql

COPY PostgreSQL/environment-postgresql.sql ./scripts/environment-postgresql.sql
RUN dos2unix ./scripts/environment-postgresql.sql

COPY $local_release_path $docker_release_path


# Remove dos2unix when we're done with it
RUN apt-get --purge remove -y dos2unix && rm -rf /var/lib/apt/lists/*
