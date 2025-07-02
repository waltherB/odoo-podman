# Odoo 18 Development Environment (Docker / Podman)

This setup provides Odoo 18 with PostgreSQL 15 running in Docker (or Podman) containers, optimized for Apple Silicon and other platforms. It supports both custom module development and Odoo core development.

**Note:** This guide primarily uses `podman` and `podman-compose` commands, which are often compatible with `docker` and `docker-compose`. If you are using Docker, you can typically substitute `docker` for `podman` and `docker-compose` for `podman-compose`. Specific differences or requirements for Docker Desktop will be noted where applicable.

## Table of Contents

- [VSCode + Podman Setup Guide](./VSCode-Podman-Guide.md)
- [Prerequisites](#prerequisites)
- [Podman Machine Configuration](#podman-machine-configuration)
  - [For Projects on External Disks](#for-projects-on-external-disks)
  - [Resource Optimization](#resource-optimization)
  - [Verification](#verification)
- [Quick Start](#quick-start)
- [Development Modes](#development-modes)
  - [Custom Module Development (Default)](#custom-module-development-default)
  - [Odoo Core Development](#odoo-core-development)
- [Project Structure](#project-structure)
- [Environment Variables (.env)](#environment-variables-env)
- [Management Commands](#management-commands)
  - [Using setup.sh (Recommended)](#using-setupsh-recommended)
  - [Manual Commands](#manual-commands)
- [Customization](#customization)
  - [Adding Custom Modules](#adding-custom-modules)
  - [Adding Python Dependencies](#adding-python-dependencies)
  - [Modifying Odoo Configuration](#modifying-odoo-configuration)
  - [Changing Ports](#changing-ports)
- [Apple Silicon Optimization](#apple-silicon-optimization)
  - [Resource Allocation](#resource-allocation)
  - [Performance Notes](#performance-notes)
- [Troubleshooting](#troubleshooting)
  - [Common Issues](#common-issues)
  - [Debug Commands](#debug-commands)
- [FAQ](#faq)
- [Features](#features)
- [Contributing](#contributing)
- [License](#license)

## Prerequisites

1.  **Containerization Tool**:
    *   **Podman (Recommended for macOS/Linux)**:
        *   Install Podman: `brew install podman` (macOS) or use your Linux package manager.
        *   Initialize Podman machine (macOS/Windows with WSL):
            ```bash
            podman machine init
            podman machine start
            ```
    *   **Docker Desktop (Alternative for macOS/Windows/Linux)**:
        *   Download and install from the [official Docker website](https://www.docker.com/products/docker-desktop/).
        *   Ensure Docker Desktop is running.

2.  **Compose Tool**:
    *   **Podman Compose**: `brew install podman-compose` (macOS) or `pip install podman-compose` (Linux).
    *   **Docker Compose**: Usually included with Docker Desktop. If not, follow Docker's installation guide.

**Note for Docker Users:** While `podman-compose` is used in examples, `docker-compose` commands are generally identical. The `setup.sh` script attempts to use `podman-compose` by default but can be modified if needed.

## Podman Machine / Docker Desktop Configuration

### For Projects on External Disks

If your project is located on an external disk (SSD, USB drive, etc.), you need to configure your containerization tool for volume mounting:

**For Podman:**

```bash
# Stop and remove existing machine
podman machine stop
podman machine rm -f

# Initialize new machine with volume mounting and optimized resources
podman machine init --cpus 4 --memory 8192 --volume /Volumes/SSD:/Volumes/SSD

# Start the machine
podman machine start
```

**Note**: Replace `/Volumes/SSD` with the actual path to your external disk where the project is located.

**For Docker Desktop (macOS/Windows):**
- Open Docker Desktop settings.
- Navigate to "Resources" > "File sharing".
- Add the path to your external disk (or its parent directory) to the list of shared directories.
- Apply and restart Docker Desktop if prompted.

### Resource Optimization

For better performance (especially on Apple Silicon M1/M2/M3):

**For Podman:**

```bash
# Stop machine
podman machine stop

# Configure resources
podman machine set --cpus 4 --memory 8192

# Start machine
podman machine start
```

**For Docker Desktop:**
- Open Docker Desktop settings.
- Navigate to "Resources" > "Advanced".
- Adjust CPUs and Memory as needed (e.g., 4 CPUs, 8GB Memory).
- Apply and restart.

### Verification

Check that your external disk is accessible (replace `/path/to/your/project` with the actual path):

**For Podman:**
```bash
# List mounted volumes (shows machine config, including mounts)
podman machine inspect

# Test access to your project directory
podman run --rm -v /path/to/your/project:/workspace alpine ls /workspace
```

**For Docker:**
```bash
# Test access to your project directory (ensure it's shared in Docker Desktop settings)
docker run --rm -v /path/to/your/project:/workspace alpine ls /workspace
```

## Quick Start

1. **Clone or setup the project**:
   ```bash
   git clone <your-repo-url>
   cd odoo-podman
   ```

2. **Create environment file**:
   ```bash
   # Copy the sample environment file
   cp sample-.env .env
   
   # Edit .env to customize your settings
   nano .env
   ```
   > **Note:** The `.env` file is in `.gitignore` for security. Always create your own `.env` from `sample-.env`.

3. **(Optional) Add Python dependencies**:
   ```bash
   # Copy the sample requirements file if you need extra Python packages
   cp sample-requirements.txt requirements.txt
   # Edit requirements.txt as needed
   nano requirements.txt
   ```

4. **Configure environment**:
   - Edit `.env` to set ports, passwords, and database name
   - Place custom modules in `./addons` directory

5. **Start the development environment**:
   ```bash
   ./setup.sh start
   ```

6. **Access Odoo**:
   - URL: `http://localhost:8069` (or your custom port from `.env`)
   - Email: `admin`
   - Password: Value of `ODOO_MASTER_PASSWORD` from `.env`

> **For advanced IDE integration and debugging, see the [VSCode + Podman Setup Guide](./VSCode-Podman-Guide.md).**

## Development Modes

### Custom Module Development (Default)

This mode is perfect for developing your own Odoo modules:

- **Custom modules**: Place your modules in the `./addons` directory
- **Core Odoo**: Uses the official Odoo 18 image with built-in core modules
- **Configuration**: Uses `odoo.conf.template` with environment variable substitution

**Setup**:
```bash
# Your custom modules go here
mkdir -p addons/my_module
# Start the environment
# This script uses podman-compose by default.
# If using docker-compose, you might run: docker-compose up -d
# Or modify setup.sh to use docker-compose.
./setup.sh start
```

### Odoo Core Development

This mode allows you to modify Odoo's core source code:

1. **Clone Odoo source**:
   ```bash
   # Clone Odoo 18 source code
   git clone https://github.com/odoo/odoo.git odoo-src
   cd odoo-src
   git checkout 18.0
   cd ..
   ```

2. **Update docker-compose.yaml**:
   ```yaml
   volumes:
     - ./addons:/mnt/extra-addons
     - ./odoo.conf.template:/etc/odoo/odoo.conf.template
     - ./entrypoint.sh:/entrypoint.sh
     # Uncomment for core development:
     - ./odoo-src:/usr/lib/python3/dist-packages/odoo
   ```

3. **Start the environment**:
   ```bash
   # This script uses podman-compose by default.
   # If using docker-compose, you might run: docker-compose up -d
   # Or modify setup.sh to use docker-compose.
   ./setup.sh start
   ```

**Note**: When developing core, changes to Odoo source code require container restart (e.g., `podman restart odoo-app` or `docker restart odoo-app`) to take effect.

> **Tip:** For advanced debugging and IDE integration, see the [VSCode + Podman Setup Guide](./VSCode-Podman-Guide.md).

## Project Structure

```
odoo-podman/
├── addons/                        # Your custom Odoo modules
│   └── home_page/                 # Example custom module
│       ├── __init__.py
│       ├── __manifest__.py
│       ├── models/
│       │   ├── __init__.py
│       │   └── home_page.py
│       ├── security/
│       │   └── ir.model.access.csv
│       └── views/
│           └── home_page_views.xml
├── docker-compose.yaml            # Container orchestration
├── Dockerfile                     # Custom Odoo image with fonts and debugpy support
├── entrypoint.sh                  # Container entrypoint script
├── odoo.conf.template             # Odoo configuration template (envsubst)
├── sample-.env                    # Example environment file (copy to .env)
├── sample-requirements.txt        # Example Python dependencies file
├── setup.sh                       # Environment management script (start, rebuild, delete)
├── VSCode-Podman-Guide.md         # Guide for VSCode + Podman integration and debugging
├── README.md                      # Main documentation
├── LICENSE                        # MIT License
├── postgres-data/                 # PostgreSQL data (auto-created, gitignored)
├── vscode-odoo-podman-setup/      # VSCode/Devcontainer config (optional, advanced)
│   ├── .devcontainer/
│   │   └── devcontainer.json
│   ├── .vscode/
│   │   └── launch.json
│   └── start-debugpy.sh
└── .gitignore                     # Git ignore rules
```

- **Note:** The `.env` file is not tracked in git; copy from `sample-.env`.
- **Note:** The `requirements.txt` file is optional; copy from `sample-requirements.txt` if needed.
- **See also:** [VSCode-Podman-Guide.md](./VSCode-Podman-Guide.md) for advanced IDE and debugging setup.

## Environment Variables (.env)

Copy `sample-.env` to `.env` and customize the values for your environment:

```bash
cp sample-.env .env
```

**Example configuration**:
```bash
# Odoo version
ODOO_VERSION=18.0

# Database configuration
POSTGRES_DB=postgres
POSTGRES_USER=odoo
POSTGRES_PASSWORD=odoo
ODOO_MASTER_PASSWORD=admin

# Port configuration
EXPOSED_ODOO_PORT=8069
EXPOSED_PG_PORT=5432
```

**Note**: The `.env` file is in `.gitignore` to keep sensitive information out of version control. Always create your own `.env` file from the sample.

## Management Commands

### Using setup.sh (Recommended)

The `setup.sh` script is configured to use `podman-compose`. If you primarily use `docker-compose`, you can:
1.  Modify `setup.sh` to use `docker-compose` by changing the `COMPOSE_CMD` variable.
2.  Or, use the manual commands listed below with `docker-compose`.

```bash
# Start the environment (uses existing image)
./setup.sh start

# Rebuild image and start (use when adding Python dependencies)
./setup.sh rebuild

# Stop and delete everything (with confirmation)
./setup.sh delete

# Show help
./setup.sh help
```

### Manual Commands

Replace `podman-compose` with `docker-compose` and `podman` with `docker` if you are using Docker.

```bash
# Start containers (e.g., podman-compose up -d or docker-compose up -d)
podman-compose up -d

# Stop containers
podman-compose down

# View logs
podman-compose logs -f

# Rebuild custom image
podman-compose build --no-cache

# Access Odoo container shell (e.g., podman exec -it odoo-app /bin/bash or docker exec -it odoo-app /bin/bash)
podman exec -it odoo-app /bin/bash

# Check container status (e.g., podman ps -a or docker ps -a)
podman ps -a
```

## Customization

### Adding Custom Modules

1. **Create your module structure**:
   ```bash
   mkdir -p addons/my_module
   cd addons/my_module
   ```

2. **Create `__manifest__.py`**:
   ```python
   {
       'name': 'My Module',
       'version': '1.0',
       'category': 'Customizations',
       'summary': 'My custom Odoo module',
       'depends': ['base'],
       'data': [],
       'installable': True,
   }
   ```

3. **Restart Odoo** to load the new module:
   ```bash
   # For Podman:
   podman restart odoo-app
   # For Docker:
   # docker restart odoo-app
   ```

### Adding Python Dependencies

If your custom modules require additional Python packages (e.g., `pyjwt` for JWT authentication), you can add them to a `requirements.txt` file:

1. **Create requirements.txt**:
   ```bash
   # Example: Add JWT support for authentication
   cp sample-requirements.txt requirements.txt
   echo "pyjwt==2.8.0" >> requirements.txt
   ```

2. **Update Dockerfile** to install requirements:
   ```dockerfile
   FROM odoo:18

   USER root
   RUN apt-get update && apt-get install -y gettext gsfonts fontconfig libfreetype6 fonts-freefont-ttf fonts-dejavu && rm -rf /var/lib/apt/lists/*
   
   # Copy and install Python requirements
   COPY requirements.txt /tmp/requirements.txt
   RUN pip3 install -r /tmp/requirements.txt
   
   USER odoo
   ```

3. **Rebuild the Docker image**:
   ```bash
   # Use the setup script to rebuild and start
   ./setup.sh rebuild
   
   # Or manually rebuild (e.g., podman-compose build --no-cache && podman-compose up -d)
   # (docker-compose build --no-cache && docker-compose up -d)
   podman-compose build --no-cache
   podman-compose up -d
   ```

**Note**: After adding new Python dependencies, you must rebuild the Docker image for the changes to take effect. Use `./setup.sh rebuild` (recommended) or your compose tool's build command.

> **For advanced debugging and IDE integration, see the [VSCode + Podman Setup Guide](./VSCode-Podman-Guide.md).**

### Modifying Odoo Configuration

Edit `odoo.conf.template` and restart the container. The template supports environment variable substitution:

```ini
[options]
admin_passwd = ${ODOO_MASTER_PASSWORD}
addons_path = /mnt/extra-addons,/usr/lib/python3/dist-packages/odoo/addons
db_host = db
db_user = ${POSTGRES_USER}
db_password = ${POSTGRES_PASSWORD}
dev = all
```

### Changing Ports

Update the `EXPOSED_ODOO_PORT` in your `.env` file and restart:

```bash
# Edit .env
EXPOSED_ODOO_PORT=8080

# Restart
./setup.sh delete
./setup.sh start
```

## Apple Silicon Optimization (Podman)

### Resource Allocation

For better performance on M1/M2/M3 with Podman:

```bash
podman machine stop
podman machine set --cpus 4 --memory 8192
podman machine start
```
Docker Desktop users should configure resources via the Docker Desktop GUI settings as mentioned earlier.

### Performance Notes

- **Volume mounts**: May have slower performance on macOS with both Docker Desktop and Podman compared to native Linux.
- **First startup**: Takes longer due to ARM64 image optimizations.
- **File watching**: Less efficient than on Linux.

## Troubleshooting

### Common Issues

1. **Port conflicts**:
   - Change ports in `.env` file
   - Check if ports are already in use: `lsof -i :8069`

2. **Database connection issues**:
   - Verify credentials in `.env` match `odoo.conf.template`
   - Check if database exists (e.g., `podman exec odoo-db psql -U odoo -l` or `docker exec odoo-db psql -U odoo -l`)

3. **Module loading issues**:
   - Check Odoo logs (e.g., `podman logs odoo-app` or `docker logs odoo-app`)
   - Verify module structure and `__manifest__.py`

4. **Font warnings**:
   - The setup includes font packages to minimize PDF generation warnings
   - Some warnings may still appear but are non-critical

5. **Permission issues**:
   ```bash
   chmod -R a+rwx postgres-data
   ```

6. **External disk access issues**:
   - Ensure Podman machine is configured with volume mounting
   - Check machine configuration: `podman machine inspect`
   - Reinitialize machine if needed with proper volume flags

7. **OCI Format Warnings with Podman Builds**:
   - If you encounter warnings related to "OCI image format" when building images with Podman (e.g., via `podman-compose build`), this might be due to the base image or specific instructions conflicting with strict OCI format expectations.
   - **Podman Tip:** The `./setup.sh rebuild` command now attempts to automatically set `BUILDAH_FORMAT=docker` when using `podman-compose` to help avoid these warnings by forcing the Docker v2 image format.
   - If you are running `podman-compose build` manually and see these warnings, you can try:
     ```bash
     export BUILDAH_FORMAT=docker
     podman-compose build --no-cache
     ```
   - This setting is specific to the Podman build process (Buildah engine). Docker users typically do not need this.

### Debug Commands

(Replace `podman` with `docker` if using Docker)

```bash
# Check container logs
podman logs odoo-app
podman logs odoo-db

# Check generated Odoo config
podman exec odoo-app cat /etc/odoo/odoo.conf

# Test database connection
podman exec odoo-app psql -h db -U ${POSTGRES_USER} -d ${POSTGRES_DB} -c "SELECT 1"

# Check available fonts
podman exec odoo-app fc-list

# Check Podman machine status (Podman specific)
podman machine list
podman machine inspect

# Test external disk access (replace with your project path)
# For Podman:
# podman run --rm -v /path/to/your/project:/workspace alpine ls /workspace
# For Docker:
# docker run --rm -v /path/to/your/project:/workspace alpine ls /workspace
podman run --rm -v /path/to/your/project:/workspace alpine ls /workspace
```

> **For advanced debugging and IDE integration, see the [VSCode + Podman Setup Guide](./VSCode-Podman-Guide.md).**

## FAQ

**Q: How do I reset my database and start fresh?**
A: Run `./setup.sh delete` to remove all containers, volumes, and data. Then run `./setup.sh start` to recreate everything.

**Q: How do I add new Python dependencies for my custom modules?**
A: Add them to `requirements.txt` (copy from `sample-requirements.txt` if needed), then run `./setup.sh rebuild`.

**Q: Where do I put my custom Odoo modules?**
A: Place them in the `addons/` directory in your project root.

**Q: How do I enable debugging with VSCode?**
A: See the [VSCode + Podman Setup Guide](./VSCode-Podman-Guide.md) for step-by-step instructions.

**Q: Why is my .env file missing after cloning?**
A: For security, `.env` is not tracked in git. Copy `sample-.env` to `.env` and edit as needed.

**Q: How do I use this on an external disk?**
A: See the [Podman Machine / Docker Desktop Configuration](#podman-machine--docker-desktop-configuration) section, specifically the "For Projects on External Disks" part.

## Features

- **Dynamic Configuration**: Uses `envsubst` for environment variable substitution
- **Font Support**: Includes font packages for proper PDF generation
- **Development Mode**: Full developer features enabled (`dev = all`)
- **ARM64 Optimized**: Custom Dockerfile for Apple Silicon
- **Flexible Setup**: Supports both custom modules and core development
- **Easy Management**: Simple setup script for common operations
- **External Disk Support**: Proper Podman machine configuration for projects on external storage

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with both custom modules and core development
5. Submit a pull request

## License

This project is licensed under the MIT License - see the [LICENSE](./LICENSE) file for details.
