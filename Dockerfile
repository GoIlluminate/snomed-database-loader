from postgres

RUN apt-get update
RUN apt-get install unzip


COPY PostgreSQL/load_release-postgresql.sh ./scripts/load_release-postgresql.sh
COPY PostgreSQL/create-database-postgres.sql ./docker-entrypoint-initdb.d/create-database-postgres.sql
COPY PostgreSQL/environment-postgresql.sql ./docker-entrypoint-initdb.d/environment-postgresql.sql
COPY Data/SnomedCT_USEditionRF2_PRODUCTION_20180301T183000Z.zip ./snomed/SnomedCT.zip
