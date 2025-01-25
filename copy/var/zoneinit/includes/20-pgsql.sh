#!/bin/bash

svcadm enable -s svc:/pkgsrc/postgresql:default

log "waiting for the socket to show up"
COUNT="0"
while ! ls /tmp/.s.PGSQL.* > /dev/null 2>&1; do
  sleep 1
  ((COUNT = COUNT + 1))
  if [[ $COUNT -eq 60 ]]; then
    log "ERROR Could not talk to PGSQL after 60 seconds"
    ERROR=yes
    break 1
  fi
done
[[ -n "${ERROR}" ]] && exit 31
log "(it took ${COUNT} seconds to start properly)"

log "create new postgres password and update database credentials"
if PGSQL_PW=$(/opt/core/bin/mdata-create-password.sh -m pgsql_pw 2> /dev/null); then
  PGPASSWORD=postgres \
    psql -U postgres -d postgres -c "alter user postgres with password '${PGSQL_PW}';"
fi

log "create user and database for pretix"
if ! psql -U postgres -lqt | cut -d \| -f 1 | grep -qw pretix 2> /dev/null; then
  PGPASSWORD=$(mdata-get pgsql_pw)
  export PGPASSWORD
  createuser -U postgres -s pretix
  createdb pretix -U postgres -O pretix \
    --encoding=UTF8 --locale=C --template=template0

  if USER_PGSQL_PW=$(/opt/core/bin/mdata-create-password.sh -m pretix_pgsql_pw 2> /dev/null); then
    psql -U pretix -d pretix -c "alter user postgres with password '${USER_PGSQL_PW}';"
  fi
fi
