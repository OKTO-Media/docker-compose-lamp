#!/bin/bash

# Copy sample.env to .env
cp sample.env .env

# Ask for project name
read -p "What is the project name? " projectName

# Ask for MySQL user
read -p "Enter MySQL user: " mysqlUser

# Ask for MySQL user
read -p "Enter MySQL Password: " mysqlUserPassword

# Automatically generate a strong password for MySQL root and user
mysqlRootPassword=$(openssl rand -base64 12)

# Update .env with project name, MySQL user, root password, and user password
sed -i "s/COMPOSE_PROJECT_NAME=.*/COMPOSE_PROJECT_NAME=${projectName}/" .env
sed -i "s/MYSQL_ROOT_PASSWORD=.*/MYSQL_ROOT_PASSWORD=${mysqlRootPassword}/" .env
sed -i "s/MYSQL_USER=.*/MYSQL_USER=${mysqlUser}/" .env
sed -i "s/MYSQL_PASSWORD=.*/MYSQL_PASSWORD=${mysqlUserPassword}/" .env
sed -i "s/MYSQL_DATABASE=.*/MYSQL_DATABASE=${projectName}/" .env

# Function to check if a port is in use
is_port_in_use() {
    netstat -tuln | grep ":$1 " > /dev/null
}

# Find an available port starting from 1000 for HOST_MACHINE_SECURE_HOST_PORT
secure_host_port=1000
while is_port_in_use $secure_host_port; do
    ((secure_host_port++))
done

# Update .env with the found port for HOST_MACHINE_SECURE_HOST_PORT
sed -i "s/HOST_MACHINE_SECURE_HOST_PORT=.*/HOST_MACHINE_SECURE_HOST_PORT=${secure_host_port}/" .env

# Find the next available port for HOST_MACHINE_PMA_SECURE_PORT
pma_port=$((secure_host_port + 1))
while is_port_in_use $pma_port; do
    ((pma_port++))
done

# Update .env with the found port for HOST_MACHINE_PMA_SECURE_PORT
sed -i "s/HOST_MACHINE_PMA_SECURE_PORT=.*/HOST_MACHINE_PMA_SECURE_PORT=${pma_port}/" .env

echo "Configuration completed. .env file is ready."