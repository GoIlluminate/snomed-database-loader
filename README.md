# SNOMED CT Database Scripts

The scripts in this repository can be used to create and populate a MYSQL, PostgreSQL of NEO4J database with a SNOMED CT terminology release distributed in the **RF2 distribution format**.

Please see the relevant sub-directories for each of the different database load scripts:

- [MYSQL](MySQL/)
- [MYSQL with optimizedviews](mysql-loader-with-optimized-views/)
- [NEO4J](NEO4J/)
- [PostgreSQL](PostgreSQL/)
  * [Automated setup](#postgresql-setup)
    * [Requirements](#postgresql-requirements)
    * [Instructions](#postgresql-instructions)

If you have any scripts for other databases, please fork this repository and create the pull request to submit any contributions.

<a name="postgresql-setup"/>

## Automated setup for PostgreSQL

<a name="postgresql-requirements"/>

### Requirements

* [Ruby](https://www.ruby-lang.org/en/documentation/installation/)
* [Docker](https://docs.docker.com/)

<a name="postgresql-instructions"/>

### Instructions

**NOTE:** The rake tasks will take care of setting up a PostgreSQL database with the provided configurations.

Run `rake ENV_VARS`. All of the following environment variables must be set:

| Environment Variable  | Value Description |
| ------------- | ------------- |
| `release_path=PATH`  | The location of the SNOMED CT release archive. |
| `module_name=MODULE_NAME`  | The module identifier. For example, US1000124 is the identifier for the US edition of the SNOMED CT release. More information about SNOMED modules can be found [here](https://confluence.ihtsdotools.org/display/DOCGLOSS/SNOMED+CT+Module) |
| `release_type=TYPE`  | The type of the SNOMED CT release. Acceptable values are `DELTA`, `SNAP`, `FULL`, and `ALL`. More information about what this means can be found [here](https://confluence.ihtsdotools.org/display/DOCRELFMT/3.2+Release+Types). |
| `db_name=DBNAME`  | The name for the database into which the data will be imported. |
| `db_host=HOSTNAME`  | The database server host or socket directory. |
| `db_port=PORT`  | The database server port number. |
| `db_username=USERNAME`  | The database user name. |
| `db_password=PASSWORD`  | The database password. |

Example: `rake release_path=./Data/SnomedCT_USEditionRF2_PRODUCTION_20180301T183000Z.zip module_name=US1000124 release_type=FULL db_name=sct_20180301 db_host=localhost db_port=5432 db_username=ps_user db_password=ps_password`

Run `rake config_help` to see the help menu.
