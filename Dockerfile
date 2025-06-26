FROM odoo:18

USER root
RUN apt-get update && apt-get install -y gettext gsfonts fontconfig libfreetype6 fonts-freefont-ttf fonts-dejavu && rm -rf /var/lib/apt/lists/*
USER odoo 