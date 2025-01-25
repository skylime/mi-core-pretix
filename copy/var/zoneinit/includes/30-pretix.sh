#!/usr/bin/env bash
# Generate pretix config

function mdata-get-default() {
  mdata-get "${1}" 2> /dev/null || echo "${2}"
}

PRETIX_CONF=/opt/pretix/.pretix.cfg
PRETIX_NAME=$(mdata-get-default pretix_name "My pretix installation")
HOSTNAME=$(hostname)

PRETIX_LOCALE_DEFAULT=$(mdata-get-default pretix_locale_default "de")
PRETIX_LOCALE_TIMEZONE=$(mdata-get-default pretix_locale_timezone "Europe/Berlin")

log "Generate pretix.cfg"
cat > "${PRETIX_CONF}" <<- EOF
[pretix]
instance_name=${PRETIX_NAME}
url=https://${HOSTNAME}
currency=EUR
datadir=/var/db/pretix
trust_x_forwarded_for=on
trust_x_forwarded_proto=on

[locale]
default=${PRETIX_LOCALE_DEFAULT}
timezone=${PRETIX_LOCALE_TIMEZONE}

[database]
backend=postgresql
name=pretix
user=pretix
; For PostgreSQL on the same host, we don't need a password because we can use
; peer authentication if our PostgreSQL user matches our unix user.
password=${PGSQL_PW}
; For local postgres authentication, you can leave it empty
host=

[redis]
location=redis://127.0.0.1/0
sessions=true

[celery]
backend=redis://127.0.0.1/1
broker=redis://127.0.0.1/2
EOF

PRETIX_MAIL_FROM=$(mdata-get-default pretix_mail_from "tickets@${HOSTNAME}")
if PRETIX_MAIL_HOST=$(mdata-get mail_smarthost 2> /dev/null); then
  if ! PRETIX_MAIL_USER=$(mdata-get mail_auth_user 2> /dev/null); then
    PRETIX_MAIL_USER=$(mdata-get-default pretix_mail_user "")
  fi
  if ! PRETIX_MAIL_PASS=$(mdata-get mail_auth_pass 2> /dev/null); then
    PRETIX_MAIL_PASS=$(mdata-get-default pretix_mail_pass "")
  fi
else
  PRETIX_MAIL_HOST=$(mdata-get-default pretix_mail_host "127.0.0.1")
  PRETIX_MAIL_USER=$(mdata-get-default pretix_mail_user "")
  PRETIX_MAIL_PASS=$(mdata-get-default pretix_mail_pass "")
fi

PRETIX_MAIL_PORT=$(mdata-get-default pretix_mail_port "587")

log "Add mail configuration"
cat >> "${PRETIX_CONF}" <<- EOF
[mail]
from=${PRETIX_MAIL_FROM}
host=${PRETIX_MAIL_HOST}
port=${PRETIX_MAIL_PORT}
user=${PRETIX_MAIL_USER}
password=${PRETIX_MAIL_PASS}
ssl=on
EOF
