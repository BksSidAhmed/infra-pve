#!/bin/sh
PORT="$1"
wget -qO- --retry-connrefused --tries=10 \
  --post-data "json={\"listen_port\":${PORT}}" \
  http://127.0.0.1:8080/api/v2/app/setPreferences
