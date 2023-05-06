## Ugrade from 9.6 to 12.7

#### Upgrade PostGIS

- Connect to both Databases with `psql`;
```bash 
psql "host=core-prod.c5mmwuonnd6t.eu-central-1.rds.amazonaws.com port=5432 dbname=JAHEZCARSPROD user=root"
psql "host=core-prod.c5mmwuonnd6t.eu-central-1.rds.amazonaws.com port=5432 dbname=sanedcoreprod user=root" 
```

- Upgrade PostGIS in both databases to 2.5.2;
``` 
alter extension postgis update TO "2.5.2";
alter extension postgis_tiger_geocoder update TO "2.5.2";
alter extension postgis_topology update TO "2.5.2";
```

- Upgrade RDS to v12.7 -- (**will take ~25 minutes**)
  - Go to RDS Console
  - Select & and modify instance
  - change DB engine version to 12.7
  - apply immediately

## Upgrade from 12.7 to 13.4


- Connect to both Databases with `psql`;
```bash 
psql "host=core-prod.c5mmwuonnd6t.eu-central-1.rds.amazonaws.com port=5432 dbname=JAHEZCARSPROD user=root"
psql "host=core-prod.c5mmwuonnd6t.eu-central-1.rds.amazonaws.com port=5432 dbname=sanedcoreprod user=root" 
```
- Make sure current version is 12.7:
```sql
SELECT VERSION ();
```
- For `sanedcoreprod` you need to drop unsupported views (unused currently)
```sql 
drop view dispatch_agg;
drop view driver_points;
drop view dispatch_distances_stats;
drop view dispatch_distances;
drop view ml;
```

- Upgrade PostGIS in both databases to 3.0.3;
```sql
alter extension postgis update TO "3.0.3";
SELECT postgis_extensions_upgrade();
```

- Upgrade RDS to v13.4  (**will take ~35 minute**)
    - Go to RDS Console
    - Select & and modify instance
    - change DB engine version to 13.4
    - apply immediately

- Make sure version is updated to 13.4
```sql
SELECT VERSION ();
```

- Change settings (**~ 5 minute**)
  - change param group to custom
  - Enable enhanced monitoring
  - Enable Performance Insights


- On both DBs, run vacuum (**~ 5 minute**):
```sql
VACUUM (verbose ON, analyze ON, parallel 64);
```

- Modify param group for `max_parallel_maintenance_workers` to 20