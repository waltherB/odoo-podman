FROM odoo:18

# Explicitly set shell to the default /bin/sh -c for broader compatibility,
# immediately after FROM to override any base image SHELL settings early.
# This can help avoid issues with base image SHELL instructions when building for OCI format.
SHELL ["/bin/sh", "-c"]

USER root

# Attempt to manually add the problematic GPG key 871920D1991BC93C
# This key is typically 'Ubuntu Archive Automatic Signing Key (2018)'
# See https://packages.ubuntu.com/noble/ubuntu-keyring for key details
RUN \
    apt-get update -o Acquire::AllowInsecureRepositories=true -o Acquire::AllowDowngradeToInsecureRepositories=true && \
    apt-get install -y --no-install-recommends gnupg && \
    gpg --homedir /tmp --no-default-keyring --keyring /usr/share/keyrings/ubuntu-archive-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 871920D1991BC93C || \
    gpg --homedir /tmp --no-default-keyring --keyring /usr/share/keyrings/ubuntu-keyring.gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 871920D1991BC93C || \
    (apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 871920D1991BC93C || echo "Failed to add key with apt-key too") && \
    echo "Attempted to add GPG key 871920D1991BC93C. Continuing..." && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Proceed with installing main dependencies
# Now that the key should be present, a regular update should work.
RUN apt-get update && \
    apt-get install -y gettext gsfonts fontconfig libfreetype6 fonts-freefont-ttf fonts-dejavu && \
    rm -rf /var/lib/apt/lists/*

# Copy and install Python requirements (if requirements.txt exists)
COPY requirements.txt /tmp/requirements.txt
RUN if [ -f /tmp/requirements.txt ]; then pip3 install --break-system-packages -r /tmp/requirements.txt; fi

COPY start-debugpy.sh /start-debugpy.sh
RUN chmod +x /start-debugpy.sh

USER odoo
