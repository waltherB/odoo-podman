# Odoo 18 Development Environment (Podman)

This setup provides Odoo 18 with PostgreSQL 15 running in Podman containers optimized for Apple Silicon.

## Prerequisites

1. Podman installed: `brew install podman`

2. Podman machine initialized:
   
   ```bash
   podman machine init
   podman machine start
   ```

## Setup Instructions

1. Create project directory:
   
   bash
- mkdir odoo-podman && cd odoo-podman
  mkdir addons postgres-data
  touch .env docker-compose.yaml odoo.conf README.md

- Copy contents to respective files:
  
  - Populate `.env`, `docker-compose.yaml`, and `odoo.conf` with the provided configurations
  
  - Place this README in the project root

- Configure environment:
  
  - Edit `.env` to set ports, passwords, and database name
  
  - Place custom modules in `./addons` directory
  
  - Configure additional Odoo settings in `odoo.conf` if needed

- Start containers:
  
  bash
1. podman-compose up -d

2. Access applications:
   
   - Odoo: [http://localhost:18069](http://localhost:18069)
   
   - PostgreSQL: `localhost:15432` (use credentials from .env)

## Management Commands

- **Stop containers**:
  
  bash

- podman-compose down

- **View Odoo logs**:
  
  bash

- podman logs odoo-app

- **Access Odoo container shell**:
  
  bash

- podman exec -it odoo-app /bin/bash

- **Restart Odoo service**:
  
  bash

- podman restart odoo-app

- **Backup database**:
  
  bash

- podman exec odoo-app odoo backup --backup-dir=/tmp

- **Check container status**:
  
  bash

- podman ps -a

## Customization

- **Add modules**: Place custom Odoo modules in `./addons` directory

- **Modify config**: Edit `odoo.conf` and restart container

- **Change ports**: Update `EXPOSED_ODOO_PORT`/`EXPOSED_PG_PORT` in `.env`

- **Adjust passwords**: Modify `ODOO_MASTER_PASSWORD` and `POSTGRES_PASSWORD` in `.env`

- **Use different Odoo version**: Change `ODOO_VERSION` in `.env`

- **Add Python dependencies**: Create `requirements.txt` in project root and rebuild containers

## Notes for Apple Silicon

1. **ARM64 Compatibility**:
   
   - Uses ARM64 images for Odoo and PostgreSQL
   
   - Optimized for M1/M2 chip performance

2. **Resource Allocation** (recommended):
   
   bash
- podman machine stop
  podman machine set --cpus 4 --memory 8192
  podman machine start

- **File System Performance**:
  
  - Volume mounts may have slower performance on macOS
  
  - For better performance:
    
    - Use `:delegated` flag for volumes (not always available in Podman)
    
    - Consider storing code in container-managed volumes

- **Permission Handling**:
  
  - If encountering permission issues:
  
  bash
1. chmod -R a+rwx postgres-data

2. **Known Issues**:
   
   - First startup may take longer due to ARM64 image optimizations
   
   - File change notifications may be less efficient than on Linux

## Troubleshooting

- **Port conflicts**: Change ports in `.env` file

- **Startup failures**: Check logs with `podman logs odoo-app`

- **Database connection issues**: Verify credentials match in `.env` and `odoo.conf`

- **Permission denied**: Ensure directory permissions for `postgres-data`

- **Module loading issues**: Check Odoo logs for Python errors

## Accessing Odoo

After startup:

- URL: `http://localhost:18069` (or your custom port)

- Email: `admin`

- Password: Value of `ODOO_MASTER_PASSWORD` from `.env`
