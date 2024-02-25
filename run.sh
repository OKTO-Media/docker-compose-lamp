#!/bin/bash

cp sample.env .env
read -p "What is the project name? " projectName
read -p "Is this a static site? (Y/N): " isStatic

is_port_in_use() {
    netstat -tuln | grep ":$1 " > /dev/null
}

# Convert input to lowercase for comparison
isStatic="${isStatic,,}"

if [[ $isStatic == "y" ]]; then
    # If it's a static site, remove MySQL and PMA related lines
    sed -i '/MYSQL_/d' .env
    sed -i '/HOST_MACHINE_PMA_SECURE_PORT/d' .env

    # Rename static-compose.yml to docker-compose.yml
    mv static-compose.yml docker-compose.yml

    # Find an available port starting from 1000 for HOST_MACHINE_SECURE_HOST_PORT
    secure_host_port=1000
    while is_port_in_use $secure_host_port; do
        ((secure_host_port++))
    done

    # Update .env with the found port for HOST_MACHINE_SECURE_HOST_PORT
    sed -i "s/HOST_MACHINE_SECURE_HOST_PORT=.*/HOST_MACHINE_SECURE_HOST_PORT=${secure_host_port}/" .env
else
    # Not a static site; proceed with MySQL setup
    read -p "Enter MySQL User: " mysqlUser
    read -p "Enter MySQL Password: " mysqlUserPassword

    # Automatically generate strong passwords
    mysqlRootPassword=$(openssl rand -base64 12)

    # Update .env with MySQL settings
    sed -i "s/MYSQL_ROOT_PASSWORD=.*/MYSQL_ROOT_PASSWORD=${mysqlRootPassword}/" .env
    sed -i "s/MYSQL_USER=.*/MYSQL_USER=${mysqlUser}/" .env
    sed -i "s/MYSQL_PASSWORD=.*/MYSQL_PASSWORD=${mysqlUserPassword}/" .env
    sed -i "s/MYSQL_DATABASE=.*/MYSQL_DATABASE=${projectName}/" .env

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
fi

# Update .env with project name outside of the if-else structure
sed -i "s/COMPOSE_PROJECT_NAME=.*/COMPOSE_PROJECT_NAME=${projectName}/" .env

echo "Configuration completed. Your port number is ${secure_host_port}"