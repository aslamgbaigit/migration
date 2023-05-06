vacuum_analyze_schema() {
    # vacuum analyze only the tables in the specified schema

    # postgres info can be supplied by either passing it as parameters to this
    # function, setting environment variables or a combination of the two
    local pg_schema="jahezdbapp"
    local pg_db="jahezdb"
    local pg_user="jahezdbapp"
    local pg_host="{{ pg_db_host }}"

    echo "Vacuuming schema \`${pg_schema}\`:"

    # extract schema table names from psql output and put them in a bash array
    local psql_tbls="\dt ${pg_schema}.*"
    local sed_str="s/${pg_schema}\s+\|\s+(\w+)\s+\|.*/\1/p"
    export PGPASSWORD=""
    local table_names=$( echo "${psql_tbls}" | psql -d "${pg_db}" -U "${pg_user}" -h "${pg_host}"  | sed -nr "${sed_str}" | grep -v "restaurant_order_p_" )
    local tables_array=( $( echo "${table_names}" | tr '\n' ' ' ) )

    # loop through the table names creating and executing a vacuum
    # command for each one
    for t in "${tables_array[@]}"; do
        echo "doing table \`${t}\`..."
        psql -d "${pg_db}" -U "${pg_user}" -h "${pg_host}" \
            -c "VACUUM (verbose ON, analyze ON) ${pg_schema}.${t};" >> logs/pg-vacuum.log 2>&1 &
    done
}

echo "Started at $(date)"
vacuum_analyze_schema
wait
echo "Finished at $(date)"