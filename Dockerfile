FROM odoo:18

USER root
RUN apt-get update && apt-get install -y gettext gsfonts && rm -rf /var/lib/apt/lists/*
USER odoo 