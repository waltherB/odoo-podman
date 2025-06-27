FROM odoo:18

USER root
RUN apt-get update && apt-get install -y gettext gsfonts fontconfig libfreetype6 fonts-freefont-ttf fonts-dejavu && rm -rf /var/lib/apt/lists/*

# Copy and install Python requirements (if requirements.txt exists)
COPY requirements.txt /tmp/requirements.txt
RUN if [ -f /tmp/requirements.txt ]; then pip3 install --break-system-packages -r /tmp/requirements.txt; fi

COPY start-debugpy.sh /start-debugpy.sh
RUN chmod +x /start-debugpy.sh

USER odoo 
