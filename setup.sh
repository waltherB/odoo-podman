#!/bin/bash

set -e

# Colors for output
green='\033[0;32m'
red='\033[0;31m'
reset='\033[0m'

# Load Odoo port from .env
ODOO_PORT=$(grep '^EXPOSED_ODOO_PORT=' .env | cut -d '=' -f2 | tr -d '"')
ODOO_PORT=${ODOO_PORT:-8069}

function usage() {
  echo -e "\nUsage: $0 [start|rebuild|delete|help]"
  echo -e "  start   Start the Odoo 18 development environment"
  echo -e "  rebuild Rebuild the Docker image and start the environment"
  echo -e "  delete  Delete all containers, volumes, and data (DANGEROUS)"
  echo -e "  help    Show this help message\n"
}

function start_env() {
  echo -e "${green}Starting Odoo 18 development environment...${reset}"
  podman-compose up -d
  echo -e "${green}Odoo should be available at http://localhost:${ODOO_PORT}${reset}"
}

function rebuild_env() {
  echo -e "${green}Rebuilding Docker image and starting Odoo 18 development environment...${reset}"
  podman-compose build --no-cache
  podman-compose up -d
  echo -e "${green}Odoo should be available at http://localhost:${ODOO_PORT}${reset}"
}

function delete_all() {
  echo -e "${red}Stopping and removing all containers, volumes, and data...${reset}"
  podman-compose down -v
  echo -e "${red}Deleting postgres-data and odoo-data directories...${reset}"
  rm -rf postgres-data odoo-data
  echo -e "${green}All containers, volumes, and data have been deleted.${reset}"
}

case "$1" in
  start)
    start_env
    ;;
  rebuild)
    rebuild_env
    ;;
  delete)
    read -p "Are you sure you want to delete ALL data? This cannot be undone! (y/N): " confirm
    if [[ "$confirm" =~ ^[Yy]$ ]]; then
      delete_all
    else
      echo "Aborted."
    fi
    ;;
  help|--help|-h|"")
    usage
    ;;
  *)
    echo -e "${red}Unknown command: $1${reset}"
    usage
    exit 1
    ;;
esac 