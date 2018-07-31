from postgres

RUN apt-get update
RUN apt-get install unzip

COPY PostgreSQL/load_release-postgresql.sh ./load_release-postgresql.sh
# Copy dockerRunner.sh ./docker-entrypoint-initdb.d/dockerRunner.sh
COPY PostgreSQL/create-database-postgres.sql ./docker-entrypoint-initdb.d/create-database-postgres.sql
COPY PostgreSQL/environment-postgresql.sql ./docker-entrypoint-initdb.d/environment-postgresql.sql
COPY Data/SnomedCT_USEditionRF2_PRODUCTION_20180301T183000Z.zip ./SnomedCT.zip
# RUN ./load_release-postgresql.sh -l ./SnomedCT.zip -m US1000124 -t FULL -d sct_20180301 -h localhost -p 5432 -u postgres