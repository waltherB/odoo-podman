#!/bin/bash
pip install debugpy
exec python3 -m debugpy --listen 0.0.0.0:5678 --wait-for-client odoo-bin -c /etc/odoo/odoo.conf
