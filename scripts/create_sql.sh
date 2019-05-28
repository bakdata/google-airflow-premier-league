#!/bin/bash
# create_sql.sh $GC_PROJECT_ID sql_file_path view_name
sql=$(sed 's/$GC_PROJECT_ID/'${1}'/g;s/$unconfigured//g' ${2})
bq mk --use_legacy_sql=false --view="$sql" --project_id ${1} ${3}