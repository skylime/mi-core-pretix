#!/usr/bin/env bash

if DDS=$(/opt/core/bin/dds); then
  zfs create "${DDS}/pretix" || true
  zfs create "${DDS}/pgsql" || true

  zfs set mountpoint=/var/db/pretix "${DDS}/pretix"
  zfs set compression=lz4 "${DDS}/pgsql"
  zfs set mountpoint=/var/pgsql "${DDS}/pgsql"
else
  mkdir -p /var/db/pretix
fi

chown -R pretix:pretix /var/db/pretix || true
