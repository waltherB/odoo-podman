FROM odoo:18

SHELL ["/bin/sh", "-c"]

USER root

# Ensure the Ubuntu Noble GPG key is present before apt-get update
RUN apt-get update || (apt-get install -y --no-install-recommends gnupg wget && \
    wget -O- https://keyserver.ubuntu.com/pks/lookup?op=get&search=0x871920D1991BC93C | gpg --dearmor > /usr/share/keyrings/ubuntu-archive-keyring.gpg && \
    apt-get update)

RUN apt-get install -y gettext gsfonts fontconfig libfreetype6 fonts-freefont-ttf fonts-dejavu && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /tmp/requirements.txt
RUN if [ -f /tmp/requirements.txt ]; then pip3 install --break-system-packages -r /tmp/requirements.txt; fi

COPY start-debugpy.sh /start-debugpy.sh
RUN chmod +x /start-debugpy.sh

USER odoo
