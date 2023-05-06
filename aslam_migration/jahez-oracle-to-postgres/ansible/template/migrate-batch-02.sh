# read target environment to set the conf file
if [ "$1" = "" ]; then
  echo "You must specify environment: test or prod"
  exit
else
  environment=$1
  ora2pgConfFile="conf/${environment}_ora2pg.conf"
fi

# check if conf file exist
if [ ! -f $ora2pgConfFile ]; then
    echo "$ora2pgConfFile not found. Exiting..."
    exit
fi

echo "Using config file: $ora2pgConfFile"

run_ora2pg() {
  t=$1
  echo "$(date) - starting migrating $t"  
  start=$SECONDS
  echo $(date) > logs/migrate-$t.log 
  oraTempDir=$(mktemp -d -p /tmp/ora2o-custom/)
  ora2pg --temp_dir $oraTempDir --jobs 20 --type COPY --limit 100 --copies 20 --allow $t --conf $ora2pgConfFile >> logs/migrate-$t.log 2>&1
  retVal=$?
  if [ $retVal -ne 0 ]; then
      echo "exited with error for $t: code is $retVal" 
      echo "Ora2pg command exited with error: code $retVal" >> logs/migrate-$t.log
      echo "$t,-1" >> timings.csv
  else 
      echo $(date) >> logs/migrate-$t.log
      end=$SECONDS
      echo "$t,$((end-start))" >> timings.csv
      echo "$(date) - finished migrating $t in $((end-start)) seconds"
  fi
}


tbls="JZ_ACTIVATION_TOKENS JZ_USER_DEVICES_TOKENS CITY_CLOSE_OPEN_NOTIFICATION MENU_OPTION_VALUES APP_USER JZ_CUSTOMERS FAVORITE ORDER_OFFER_MAP PENDING_MENU_ITEM_VARIANT MENU_ITEM_VARIANT MISSING_ITEM_HISTORY APP_USER_JAYPAY MADA_CREDIT_CARD MENU_OPTIONS"
for t in $tbls; do
  run_ora2pg $t &
done

wait
echo "Finished all tables ==========="

