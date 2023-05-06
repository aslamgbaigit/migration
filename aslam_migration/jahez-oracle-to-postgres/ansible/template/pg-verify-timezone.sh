show_timezone() {
    # vacuum analyze only the tables in the specified schema

    # postgres info can be supplied by either passing it as parameters to this
    # function, setting environment variables or a combination of the two
    local pg_schema="jahezdbapp"
    local pg_db="jahezdb"
    local pg_user="jahezdbapp"
    local pg_host="{{ pg_db_host }}"
    local pg_host_ro="{{ pg_db_host_ro }}"
    export PGPASSWORD=""

    echo "Timezone for writer:"
    psql -d "${pg_db}" -U "${pg_user}" -h "${pg_host}" \
                -c "show timezone;"

    echo "Timezone for reader:"
    psql -d "${pg_db}" -U "${pg_user}" -h "${pg_host_ro}" \
                -c "show timezone;"
}


show_timezone