# SNOMED CT DATABASE

SQL scripts to create and populate a PostgreSQL database with a SNOMED CT terminology release.

**NOTE:** This script is not directly supported by SNOMED International and has not been fully tested by the SNOMED International team. It has been kindly donated by others in the SNOMED CT community.

## Minimum Specification

- PostgreSQL v9

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

1. Download the SNOMED CT terminology release from the IHTSDO website.
2. Create the database using the `create-database-postgres.sql` script.
    * Skip this step or perform it manually if you'd like the data to be loaded into an existing database or a different one than the script specifies.
3. Create the tables using the `environment-postgresql.sql` script.
    * Currently, this script only creates tables for full files.
4. Update the `load-postgresql.sql` script as specified in its comments so it will work with your release files.
    * Instead of editing the location of the release files in the SQL script, you can create a symlink that points to the appropriate directory (e.g. `ln -s /your/snomed/directory RF2Release`).
5. Load the database that was created using the edited load script (in step 4) from the relevant command prompt.
