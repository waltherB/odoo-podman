# Odoo 18 Development Environment (Podman)

This setup provides Odoo 18 with PostgreSQL 15 running in Podman containers optimized for Apple Silicon, supporting both custom module development and Odoo core development.

## Prerequisites

1. **Podman installed**: `brew install podman`

2. **Podman machine initialized**:
   ```bash
   podman machine init
   podman machine start
   ```

3. **Podman Compose**: `brew install podman-compose`

## Podman Machine Configuration

### For Projects on External Disks

If your project is located on an external disk (SSD, USB drive, etc.), you need to configure Podman machine with volume mounting:

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

### Resource Optimization

For better performance on Apple Silicon (M1/M2/M3):

```bash
# Stop machine
podman machine stop

# Configure resources
podman machine set --cpus 4 --memory 8192

# Start machine
podman machine start
```

### Verification

Check that your external disk is accessible:

```bash
# List mounted volumes
podman machine inspect

# Test access to your project directory
podman run --rm -v /Volumes/SSD/Documents-SSD/Tools/odoo-podman:/workspace alpine ls /workspace
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

3. **Configure environment**:
   - Edit `.env` to set ports, passwords, and database name
   - Place custom modules in `./addons` directory

4. **Start the development environment**:
   ```bash
   ./setup.sh start
   ```

5. **Access Odoo**:
   - URL: `http://localhost:8069` (or your custom port from `.env`)
   - Email: `admin`
   - Password: Value of `ODOO_MASTER_PASSWORD` from `.env`

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
   ./setup.sh start
   ```

**Note**: When developing core, changes to Odoo source code require container restart to take effect.

## Project Structure

```
odoo-podman/
├── addons/                    # Your custom Odoo modules
├── odoo-src/                  # Odoo core source (for core development)
├── docker-compose.yaml        # Container orchestration
├── Dockerfile                 # Custom Odoo image with fonts
├── odoo.conf.template         # Odoo configuration template
├── entrypoint.sh              # Container entrypoint script
├── setup.sh                   # Environment management script
├── .env                       # Environment variables
└── postgres-data/             # PostgreSQL data (auto-created)
```

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

```bash
# Start containers
podman-compose up -d

# Stop containers
podman-compose down

# View logs
podman-compose logs -f

# Rebuild custom image
podman-compose build --no-cache

# Access Odoo container shell
podman exec -it odoo-app /bin/bash

# Check container status
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
   podman restart odoo-app
   ```

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

## Apple Silicon Optimization

### Resource Allocation

For better performance on M1/M2/M3:

```bash
podman machine stop
podman machine set --cpus 4 --memory 8192
podman machine start
```

### Performance Notes

- **Volume mounts**: May have slower performance on macOS
- **First startup**: Takes longer due to ARM64 image optimizations
- **File watching**: Less efficient than on Linux

## Troubleshooting

### Common Issues

1. **Port conflicts**:
   - Change ports in `.env` file
   - Check if ports are already in use: `lsof -i :8069`

2. **Database connection issues**:
   - Verify credentials in `.env` match `odoo.conf.template`
   - Check if database exists: `podman exec odoo-db psql -U odoo -l`

3. **Module loading issues**:
   - Check Odoo logs: `podman logs odoo-app`
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

### Debug Commands

```bash
# Check container logs
podman logs odoo-app
podman logs odoo-db

# Check generated Odoo config
podman exec odoo-app cat /etc/odoo/odoo.conf

# Test database connection
podman exec odoo-app psql -h db -U odoo -d postgres -c "SELECT 1"

# Check available fonts
podman exec odoo-app fc-list

# Check Podman machine status
podman machine list
podman machine inspect

# Test external disk access
podman run --rm -v /Volumes/SSD/Documents-SSD/Tools/odoo-podman:/workspace alpine ls /workspace
```

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

This project is licensed under the MIT License - see the LICENSE file for details.

### Adding Python Dependencies

If your custom modules require additional Python packages (e.g., `pyjwt` for JWT authentication), you can add them to a `requirements.txt` file:

1. **Create requirements.txt**:
   ```bash
   # Example: Add JWT support for authentication
   echo "pyjwt==2.8.0" > requirements.txt
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
   
   # Or manually rebuild
   podman-compose build --no-cache
   podman-compose up -d
   ```

**Note**: After adding new Python dependencies, you must rebuild the Docker image for the changes to take effect. Use `./setup.sh rebuild` for convenience.

### Modifying Odoo Configuration
