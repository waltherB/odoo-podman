#!/bin/bash

# Install envsubst if not found
if ! command -v envsubst &> /dev/null; then
    echo "Installing envsubst..."
    apt-get update > /dev/null && apt-get install -y gettext-base
fi

# Substitute environment variables in the template
envsubst < /etc/odoo/odoo.conf.template > /etc/odoo/odoo.conf

# Execute the original Odoo command
exec "$@"
