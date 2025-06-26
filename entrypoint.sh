#!/bin/bash
set -e

# Substitute environment variables in odoo.conf.template to odoo.conf
if [ -f /etc/odoo/odoo.conf.template ]; then
  echo "Generating odoo.conf from template..."
  envsubst < /etc/odoo/odoo.conf.template > /etc/odoo/odoo.conf
fi

# Start Odoo
exec "$@" 