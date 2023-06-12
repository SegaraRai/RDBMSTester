#!/bin/bash

# MariaDB
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mysql/mariadb.conf.d/50-server.cnf

# PostgreSQL
# Find installed PostgreSQL versions
pg_versions=$(ls /etc/postgresql/)

# Loop through all found versions
for version in $pg_versions
do
  # Set the configuration file paths
  pg_conf="/etc/postgresql/$version/main/postgresql.conf"
  pg_hba_conf="/etc/postgresql/$version/main/pg_hba.conf"

  # Check if configuration files exist
  if [ -f $pg_conf ] && [ -f $pg_hba_conf ]; then
    echo "Updating PostgreSQL configuration for version $version..."

    # Modify postgresql.conf to allow listening on all addresses
    sudo sed -i "s/^#listen_addresses.*/listen_addresses = '*'/" $pg_conf

    # Allow connections from any address in pg_hba.conf
    echo "host    all             all             0.0.0.0/0               md5" | sudo tee -a $pg_hba_conf > /dev/null
  else
    echo "Configuration files for PostgreSQL version $version not found. Skipping..."
  fi
done
