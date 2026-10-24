#!/bin/bash

set -euo pipefail

echo "=== Starting Unbound container ==="

# ----------------------------
# Timezone setup
# ----------------------------
if [ -n "${TZ:-}" ]; then
  ln -snf /usr/share/zoneinfo/"$TZ" /etc/localtime
  echo "$TZ" > /etc/timezone
  echo "Timezone set to $TZ"
fi

# ----------------------------
# Environment export (optional for cron/tools)
# ----------------------------
printenv > /etc/environment

echo "--> Setting up anchor key..."
unbound-anchor -a "/etc/unbound/root.key" || true

echo "--> Setting unbound certificates..."
# Generate control keys/certs if they don't exist yet
if [ ! -f /etc/unbound/unbound_server.pem ]; then
    unbound-control-setup -d /etc/unbound || true
fi

echo "--> Starting Unbound daemon in foreground..."

# Start Postfix in foreground so the container stays alive
exec unbound -d -c /etc/unbound/unbound.conf
