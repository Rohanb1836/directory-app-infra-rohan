#!/bin/bash
# Runs once, when the Postgres data volume is first created.
# Creates separate databases and owner roles for the application and for Keycloak (ADR-0003, ADR-0016).
set -euo pipefail

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname postgres <<-EOSQL
  CREATE ROLE blackpages LOGIN PASSWORD '${APP_DB_PASSWORD}';
  CREATE DATABASE blackpages OWNER blackpages;

  CREATE ROLE keycloak LOGIN PASSWORD '${KEYCLOAK_DB_PASSWORD}';
  CREATE DATABASE keycloak OWNER keycloak;

  -- Neither role can connect to the other's database
  REVOKE CONNECT ON DATABASE blackpages FROM PUBLIC;
  REVOKE CONNECT ON DATABASE keycloak   FROM PUBLIC;
  GRANT  CONNECT ON DATABASE blackpages TO blackpages;
  GRANT  CONNECT ON DATABASE keycloak   TO keycloak;
EOSQL

# Extensions for the application database only
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname blackpages <<-EOSQL
  CREATE EXTENSION IF NOT EXISTS postgis;
  CREATE EXTENSION IF NOT EXISTS pg_trgm;
  CREATE EXTENSION IF NOT EXISTS unaccent;
EOSQL
