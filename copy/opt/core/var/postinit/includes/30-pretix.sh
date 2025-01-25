#!/usr/bin/env bash

echo "* Install working dependencies"
pkgin -y in build-essential rust

echo "* Install pretix"
su pretix -c "/opt/pretix/venv/bin/pip3 install pretix gunicorn"

echo "* Migrate pretix"
su pretix -c "/opt/pretix/venv/bin/python3 -m pretix migrate"

echo "* Rebuild pretix (ignore errors because try to access data in /usr/lib/locale/C/LC_MESSAGES)"
su pretix -c "/opt/pretix/venv/bin/python3 -m pretix rebuild" || true

echo "* Remove unrequired dependencies after setup"
pkgin -y remove build-essential rust
pkgin -y autoremove

echo "* Enable services"
svcadm enable svc:/application/pretix-worker:default
svcadm enable svc:/application/pretix-web:default
