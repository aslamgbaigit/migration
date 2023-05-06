
## Pre-Migration Steps

- Stop Logstash service
- Take a backup of DDL statements of foreign key constraints
```sql 
select 'alter table '||quote_ident(ns.nspname)||'.'||quote_ident(tb.relname)||
       ' add constraint '||quote_ident(conname)||' '||
       pg_get_constraintdef(c.oid, true) || ';' as ddl
from pg_constraint c
  join pg_class tb on tb.oid = c.conrelid
  join pg_namespace ns on ns.oid = tb.relnamespace
where ns.nspname in ('jahezdbapp')
 and c.contype = 'f';
```
- Stop cron job for refreshing menu items mv:
```sql
update cron.job set active = false where job.jobid != -1
```
- Drop foreign key constraints
```sql
SELECT 'alter table '|| rel.relname || ' drop constraint '||con.conname|| ';'
FROM pg_catalog.pg_constraint con
         INNER JOIN pg_catalog.pg_class rel
                    ON rel.oid = con.conrelid
         INNER JOIN pg_catalog.pg_namespace nsp
                    ON nsp.oid = connamespace
WHERE nsp.nspname = 'jahezdbapp'
  and con.contype='f';
```

- Truncate table `audit_log`


- confirm no fk exist by running above command

- Drop sequences
```sql
select 'drop sequence ' || sequencename || ';'
from pg_sequences
where schemaname = 'jahezdbapp'
```

- ensure all sequences are dropped by running above command again


- Change Timezone for Postgres to `Asia/Riyadh`:
  - Go to aurora cluster
  - select param group
  - edit `timezone` to `Asia/Riyadh`
  - Reboot writer instance
  - verify timezone change by running script `./prod_pg-verify-timezone.sh`


- Create new ouath access token table
```sql
CREATE SEQUENCE "MIGRATION_OAUTH_TOKENS_SQQQ" START WITH 1 INCREMENT BY 1;

create table OAUTH_ACCESS_TOKEN_MIG
(
	TOKEN_ID VARCHAR2(256),
	TOKEN BLOB,
	AUTHENTICATION_ID VARCHAR2(256) not null
		primary key,
	USER_NAME VARCHAR2(256),
	CLIENT_ID VARCHAR2(256),
	AUTHENTICATION BLOB,
	REFRESH_TOKEN VARCHAR2(256),
	MIGRATION_ID numeric(10) not null
);

insert into OAUTH_ACCESS_TOKEN_MIG(TOKEN_ID, TOKEN, AUTHENTICATION_ID, USER_NAME, CLIENT_ID, AUTHENTICATION,REFRESH_TOKEN, MIGRATION_ID)
    select  TOKEN_ID,TOKEN,AUTHENTICATION_ID,USER_NAME,CLIENT_ID,AUTHENTICATION,REFRESH_TOKEN,MIGRATION_OAUTH_TOKENS_SQQQ.nextval from OAUTH_ACCESS_TOKEN;

create unique index OAUTH_MIGRATION_ID_IDX
	on OAUTH_ACCESS_TOKEN_MIG (MIGRATION_ID);


```
## Post-Migration steps
- Change Timezone for Postgres to `UTC`:
  - Go to aurora cluster
  - select param group
  - edit `timezone` to `UTC`
  - Reboot writer instance
  - verify timezone change by running script  `./prod_pg-verify-timezone.sh`
  

- Fix Branch boolean columns `null` to `false`
```sql
update branch set live_flag = false where live_flag is null;
update branch set auto_approve_flag = false where auto_approve_flag is null;
```

- Verify Data Migration is complete
  - Verify rows count by running the following script:
   ```bash
   ora2pg --type TEST_COUNT --conf conf/prod_ora2pg.conf --parallel 200
   ```
  - Verify data integrity  
  

- **Create Sequences**. Retrieve the last sequence at Oracle, and create new sequences with where it last stopped at Oracle:

```sql
select 'CREATE SEQUENCE IF NOT EXISTS ' || sequence_name ||
       ' INCREMENT BY '|| INCREMENT_BY ||
       ' START WITH ' || (last_number +1) ||
       ' MAXVALUE '  || case when MAX_VALUE  >= 9223372036854775807 then 9223372036854775807 else MAX_VALUE end ||
       ' MINVALUE ' || MIN_VALUE ||
       ' NO CYCLE '||
       ' CACHE ' || DECODE(CACHE_SIZE, 0, 1, CACHE_SIZE) || ';'
from all_sequences where SEQUENCE_OWNER='JAHEZDBAPP';
```

- Create FK constraints from the backup DDLs taken above (Pre-migration)


- Execute `Vacuum Analyze` on all tables on postgres by running the following script:
```bash
./vaccum-pg.sh
```

- Change `max_maintenance_parallel_workers` to `8` in DB & Cluster param group.

- Enalbe cron jobs in pg:
```sql
update cron.job set active = true where job.jobid != -1
```

- Start Logstash with postgres pipelines




