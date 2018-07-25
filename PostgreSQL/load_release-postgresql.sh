#!/bin/bash
set -e;

cd "`dirname "$0"`"
baseDir="$(pwd)"
releasePath=$1
dbName=$2
releaseType=$3
moduleStr=$4
dbUsername=$5
dbPort=$6

if [ -z ${moduleStr} ]
then
	echo "Usage <release location> <db schema name> <DELTA|SNAP|FULL|ALL> <module string> [<postgres username> <postgres port>]"
	exit -1
fi

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
	*) echo "Release type ${releaseType} not recognised"
	exit -1;
	;;
esac

	
# Determine the release date from the filenames
releaseDate=`ls -1 ${localExtract}/*.txt | head -1 | egrep -o '[0-9]{8}'`	

function addLoadScript() {
	for fileType in ${fileTypes[@]}; do
		fileName=${1/TYPE/${fileType}}
		fileName=${fileName/DATE/${releaseDate}}
        fileName=${fileName/INT/${moduleStr}}

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

psql -h localhost -U ${dbUsername} -p ${dbPort} -d ${dbName} << EOF
	\ir create-database-postgres.sql;
	\ir environment-postgresql.sql;
	\ir ${generatedLoadScript};
EOF

rm -rf $localExtract
# We'll leave the generated environment & load scripts for inspection
