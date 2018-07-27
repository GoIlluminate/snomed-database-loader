#!/bin/bash
set -e;

cd "`dirname "$0"`"
baseDir="$(pwd)"

# lookit all these variables for configurations
declare releasePath
declare releaseType
declare moduleName
declare dbName
declare dbHost
declare dbPort
declare dbUsername

function showErrorMessage() {
    echo "$1"
    echo ""
    echo "Try '$0 -H' for more information."
}

while getopts ":d:h:Hl:m:p:t:u:" opt; do
    case ${opt} in
        d )
            dbName=$OPTARG
            ;;
        h )
            dbHost=$OPTARG
            ;;
        H )
            echo "Usage: $0 CONFIGURATIONS"
            echo "  or:  $0 -H"
            echo ""
            echo "Create and populate a PostgreSQL database with a SNOMED CT terminology release."
            echo ""
            echo "== Configurations (required) =="
            echo ""
            echo "SNOMED CT release configurations:"
            echo "  -l        release archive location"
            echo "  -m        module name (e.g. INT, US1000124)"
            echo "  -t        release type"
            echo "               options are DELTA, SNAP, FULL, or ALL"
            echo "               SNAP is for snapshot, and ALL is for delta, snapshot, and full"
            echo ""
            echo "Database configurations:"
            echo "  -d        database name to connect to"
            echo "  -h        database server host or socket directory"
            echo "  -p        database server port"
            echo "  -u        database user name"
            echo ""
            echo "== Other (optional)"
            echo ""
            echo "  -H        display this help and exit"

            exit 1
            ;;
        l )
            releasePath="`dirname "$OPTARG"`"
            ;;
        m )
            moduleName=$OPTARG
            ;;
        p )
            dbPort=$OPTARG
            ;;
        t )
            releaseType=$OPTARG
            ;;
        u )
            dbUsername=$OPTARG
            ;;
        : ) # missing option argument
            declare missingArgDesc

            case ${OPTARG} in
                d )
                    missingArgDesc="the database name"
                    ;;
                h )
                    missingArgDesc="the database server host or socket directory"
                    ;;
                l )
                    missingArgDesc="the path to the SNOMED archive"
                    ;;
                m )
                    missingArgDesc="the name of the SNOMED module"
                    ;;
                p )
                    missingArgDesc="the database server port"
                    ;;
                t )
                    missingArgDesc="the type of the SNOMED release"
                    ;;
                u )
                    missingArgDesc="the database user name"
                    ;;
            esac

            showErrorMessage "Option -$OPTARG requires $missingArgDesc as an argument."

            exit -1
            ;;

        \? ) # invalid option
            showErrorMessage "$0: invalid option -- '$OPTARG'"
            ;;
    esac
done



# Unzip the files here, junking the structure
localExtract="tmp_extracted"
generatedLoadScript="tmp_loader.sql"
generatedEnvScript="tmp_environment-postgresql.sql"

# What types of files are we loading - delta, snapshot, full or all?
case "${releaseType}" in 
	'DELTA') fileTypes=(Delta)
		unzip -j ${releasePath} "*Delta*" -d ${localExtract}
	;;
	'SNAP') fileTypes=(Snapshot)
		unzip -j ${releasePath} "*Snapshot*" -d ${localExtract}
	;;
	'FULL') fileTypes=(Full)
		unzip -j ${releasePath} "*Full*" -d ${localExtract}
	;;
	'ALL') fileTypes=(Delta Snapshot Full)	
		unzip -j ${releasePath} -d ${localExtract}
	;;
	*) echo "Release type '${releaseType}' not recognised"
	exit -1;
	;;
esac

	
# Determine the release date from the filenames
releaseDate=`ls -1 ${localExtract}/*.txt | head -1 | egrep -o '[0-9]{8}'`	

function addLoadScript() {
	for fileType in ${fileTypes[@]}; do
		fileName=${1/TYPE/${fileType}}
		fileName=${fileName/DATE/${releaseDate}}
        fileName=${fileName/INT/${moduleName}}

		# Check file exists - try beta version if not
		if [ ! -f ${localExtract}/${fileName} ]; then
			origFilename=${fileName}
			fileName="x${fileName}"
			if [ ! -f ${localExtract}/${fileName} ]; then
				echo "Unable to find ${origFilename} or beta version"
				exit -1
			fi
		fi

		tableName=${2}_`echo $fileType | head -c 1 | tr '[:upper:]' '[:lower:]'`

        # \copy must be entirely on one line
		echo -e "\\COPY ${tableName} FROM '"${baseDir}/${localExtract}/${fileName}"' WITH (FORMAT csv, HEADER true, DELIMITER E'	', QUOTE E'\b');" >> ${generatedLoadScript}
		echo -e ""  >> ${generatedLoadScript}
	done
}

echo -e "\nGenerating loading script for $releaseDate"
echo "/* Generated Loader Script */" >  ${generatedLoadScript}
echo "" >> ${generatedLoadScript}
echo "set schema 'snomedct';" >> ${generatedLoadScript}
echo "" >> ${generatedLoadScript}
addLoadScript sct2_Concept_TYPE_INT_DATE.txt concept
addLoadScript sct2_Description_TYPE-en_INT_DATE.txt description
addLoadScript sct2_StatedRelationship_TYPE_INT_DATE.txt stated_relationship
addLoadScript sct2_Relationship_TYPE_INT_DATE.txt relationship
addLoadScript sct2_TextDefinition_TYPE-en_INT_DATE.txt textdefinition
addLoadScript der2_cRefset_AttributeValueTYPE_INT_DATE.txt attributevaluerefset
addLoadScript der2_cRefset_LanguageTYPE-en_INT_DATE.txt langrefset
addLoadScript der2_cRefset_AssociationTYPE_INT_DATE.txt associationrefset

psql -h ${dbHost} -U ${dbUsername} -p ${dbPort} -d ${dbName} << EOF
	\ir create-database-postgres.sql;
	\ir environment-postgresql.sql;
	\ir ${generatedLoadScript};
EOF

rm -rf $localExtract
# We'll leave the generated environment & load scripts for inspection
