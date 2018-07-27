# SNOMED CT DATABASE

SQL scripts to create and populate a PostgreSQL database with a SNOMED CT terminology release.

**NOTE:** This script is not directly supported by SNOMED International and has not been fully tested by the SNOMED International team. It has been kindly donated by others in the SNOMED CT community.

## Minimum Specification

- PostgreSQL v9

# Creating the SNOMED CT schema on PostgreSQL

PostgreSQL is an [`ORDBMS`](http://en.wikipedia.org/wiki/ORDBMS); therefore, every database is a self-contained object. A database contains logins, groups, one or more schemas, etc., and every connection is related to a single database.

## Differences from the MySQL version

- Does not need `engine=myisam`, which by itself is a bit strange, as `myisam` does not support foreign keys.
- Changes `database` for `schema`
- Uses the `unique` constraint instead of `key`

## Scripted Installation (Mac & Unix)

`./load_release-postgresql.sh -l <release location> -m <module name> -t <release type> -d <database name> -h <database host> -p <database port> -u <database user name>`

All of the flags listed below must be used for the script to run.

| Flag  | Argument Description |
| ------------- | ------------- |
| `-l <release location>`  | The location of the SNOMED CT release archive. |
| `-m <module name>`  | The module identifier. For example, US1000124 is the identifier for the US edition of the SNOMED CT release. More information about SNOMED modules can be found [here](https://confluence.ihtsdotools.org/display/DOCGLOSS/SNOMED+CT+Module) |
| `-t <release type>`  | The type of the SNOMED CT release. Acceptable values are `DELTA`, `SNAP`, `FULL`, and `ALL`. More information about what this means can be found [here](https://confluence.ihtsdotools.org/display/DOCRELFMT/3.2+Release+Types). |
| `-d <database name>`  | The name of the database into which the data will be imported. |
| `-h <database host>`  | The database server host or socket directory. |
| `-p <database port>`  | The database server port number. |
| `-u <database user name>`  | The database user name. |


Example: `./load_release-postgresql.sh -l ~/Documents/SnomedCT_RF2Release_US1000124_20180301.zip -m US1000124 -t FULL -d sct_20180301 -h localhost -p 5432 -u postgres`

Run `./load_release-postgresql.sh -H` to see the help menu.

## Manual Installation

1. Download the SNOMED CT terminology release from the IHTSDO website
2. Create the database using the db create-database-postgres.sql script or skip/perform this action manually if you'd like the data to be loaded into an existing/different database.
3. Create the tables using the db appropriate environment.sql script. The default file creates tables for full, snapshot and delta files and there's also a -full-only version.
4. Edit the db appropriate load.sql script with the correct location of the SNOMED CT release files An alternative under unix or mac would be to create a symlink to the appropriate directory eg `ln -s /your/snomed/directory RF2Release`
5. Load the database that was created using the edited `load.sql` script from the relevant command prompt, again by default for full, snapshot, and delta, unless you only want the full version.
