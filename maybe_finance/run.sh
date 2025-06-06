#!/usr/bin/env bash
CONFIG_PATH="/data/options.json"

# Ensure the file exists
if [ ! -f "$CONFIG_PATH" ]; then
    echo "Config file not found: $CONFIG_PATH"
    exit 1
fi

# Read user-configured values
POSTGRES_USER=$(jq --raw-output '.postgres_user // "postgres"' "$CONFIG_PATH")
POSTGRES_PASSWORD=$(jq --raw-output '.postgres_password' "$CONFIG_PATH")
SECRET_KEY_BASE=$(jq --raw-output '.secret_key_base' "$CONFIG_PATH")
DB_HOST=$(jq --raw-output '.db_host // "172.30.32.1"' "$CONFIG_PATH")
DB_PORT=$(jq --raw-output '.db_port // "5432"' "$CONFIG_PATH")
REDIS_URL=$(jq --raw-output '.redis_url // "redis://redis:6379/1"' "$CONFIG_PATH")

#APP_DOMAIN=$(jq --raw-output '.app_domain // "http://localhost"' "$CONFIG_PATH")
PLAID_CLIENT_ID=$(jq --raw-output '.plaid_client_id // empty' "$CONFIG_PATH")
PLAID_SECRET=$(jq --raw-output '.plaid_secret // empty' "$CONFIG_PATH")
PLAID_ENV=$(jq --raw-output '.plaid_env // empty' "$CONFIG_PATH")
OPENAI_ACCESS_TOKEN=$(jq --raw-output '.openai_access_token // empty' "$CONFIG_PATH")
SELF_HOSTED=$(jq --raw-output '.self_hosted' "$CONFIG_PATH")
RAILS_FORCE_SSL=$(jq --raw-output '.rails_force_ssl' "$CONFIG_PATH")
RAILS_ASSUME_SSL=$(jq --raw-output '.rails_assume_ssl' "$CONFIG_PATH")
GOOD_JOB_EXECUTION_MODE=$(jq --raw-output '.good_job_execution_mode // "async"' "$CONFIG_PATH")
REQUIRE_INVITE_CODE=$(jq --raw-output '.require_invite_code // true' "$CONFIG_PATH")



echo "DEBUG: Configured values:"
echo "POSTGRES_USER: $POSTGRES_USER"
echo "POSTGRES_PASSWORD: HIDDEN"
echo "DB_HOST: $DB_HOST"
echo "DB_PORT: $DB_PORT"
echo "REDIS_URL: $REDIS_URL"
#echo "APP_DOMAIN: $APP_DOMAIN"
echo "PLAID_CLIENT_ID: $PLAID_CLIENT_ID"
echo "PLAID_SECRET: HIDDEN"
echo "PLAID_ENV: $PLAID_ENV"
echo "SELF_HOSTED: $SELF_HOSTED"
echo "RAILS_FORCE_SSL: $RAILS_FORCE_SSL"
echo "RAILS_ASSUME_SSL: $RAILS_ASSUME_SSL"
echo "GOOD_JOB_EXECUTION_MODE: $GOOD_JOB_EXECUTION_MODE"
echo "REQUIRE_INVITE_CODE: $REQUIRE_INVITE_CODE"
echo "OPENAI_ACCESS_TOKEN: HIDDEN"

# Export as environment variables
export POSTGRES_USER="${POSTGRES_USER}"
export POSTGRES_PASSWORD="${POSTGRES_PASSWORD}"
export SECRET_KEY_BASE="${SECRET_KEY_BASE}"
export DB_HOST="${DB_HOST}"
export DB_PORT="${DB_PORT}"
export REDIS_URL="${REDIS_URL}"

#export APP_DOMAIN="${APP_DOMAIN}"

# Export optional Plaid configuration if set
[ -n "$PLAID_CLIENT_ID" ] && export PLAID_CLIENT_ID="${PLAID_CLIENT_ID}"
[ -n "$PLAID_SECRET" ] && export PLAID_SECRET="${PLAID_SECRET}"
[ -n "$PLAID_ENV" ] && export PLAID_ENV="${PLAID_ENV}"
[ -n "$OPENAI_ACCESS_TOKEN" ] && export OPENAI_ACCESS_TOKEN="${OPENAI_ACCESS_TOKEN}"

export SELF_HOSTED="${SELF_HOSTED}"
export RAILS_FORCE_SSL="${RAILS_FORCE_SSL}"
export RAILS_ASSUME_SSL="${RAILS_ASSUME_SSL}"
export GOOD_JOB_EXECUTION_MODE="${GOOD_JOB_EXECUTION_MODE}"
export REQUIRE_INVITE_CODE="${REQUIRE_INVITE_CODE}"



# OWN CONFIG, not from the original entrypoint
export UPGRADES_ENABLED=false
export UPGRADES_MODE=manual # auto, manual
export UPGRADES_TARGET=release # `release` or `commit`

export GITHUB_REPO_OWNER=maybe-finance
export GITHUB_REPO_NAME=maybe
export GITHUB_REPO_BRANCH=main

# Pass through to original entrypoint with CMD arguments
exec /rails/bin/docker-entrypoint "$@"
