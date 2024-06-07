#!/usr/bin/env bash

# Remove docker-compose.yml if it exists
rm -f docker-compose.yml

# Copy sample.env to .env
cp sample.env .env

# Read user inputs
read -p "What is the project name? " projectName
read -p "Is this a static site? (Y/N): " isStatic

# Function to check if a port is in use
is_port_in_use() {
    netstat -tuln | grep ":$1 " > /dev/null
}

# Use case-insensitive match for user input
case "$isStatic" in
    [Yy])
        # If it's a static site, remove MySQL and PMA related lines
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' '/MYSQL_/d' .env
            sed -i '' '/HOST_MACHINE_PMA_SECURE_PORT/d' .env
        else
            sed -i '/MYSQL_/d' .env
            sed -i '/HOST_MACHINE_PMA_SECURE_PORT/d' .env
        fi

        # Copy and rename static-compose.yml to docker-compose.yml
        cp static-compose.yml docker-compose.yml

        # Find an available port
        secure_host_port=1000
        while is_port_in_use $secure_host_port; do
            ((secure_host_port++))
        done

        # Update .env with the found port
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s/HOST_MACHINE_SECURE_HOST_PORT=.*/HOST_MACHINE_SECURE_HOST_PORT=${secure_host_port}/" .env
        else
            sed -i "s/HOST_MACHINE_SECURE_HOST_PORT=.*/HOST_MACHINE_SECURE_HOST_PORT=${secure_host_port}/" .env
        fi
        ;;
    [Nn])
        read -p "Enter MySQL User: " mysqlUser
        read -p "Enter MySQL Password: " mysqlUserPassword

        # Copy and rename cms-compose.yml to docker-compose.yml
        cp cms-compose.yml docker-compose.yml

        # Generate a random MySQL root password
        mysqlRootPassword=$(openssl rand -base64 12)

        # Update .env with MySQL credentials
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s/MYSQL_ROOT_PASSWORD=.*/MYSQL_ROOT_PASSWORD=${mysqlRootPassword}/" .env
            sed -i '' "s/MYSQL_USER=.*/MYSQL_USER=${mysqlUser}/" .env
            sed -i '' "s/MYSQL_PASSWORD=.*/MYSQL_PASSWORD=${mysqlUserPassword}/" .env
            sed -i '' "s/MYSQL_DATABASE=.*/MYSQL_DATABASE=${projectName}/" .env
        else
            sed -i "s/MYSQL_ROOT_PASSWORD=.*/MYSQL_ROOT_PASSWORD=${mysqlRootPassword}/" .env
            sed -i "s/MYSQL_USER=.*/MYSQL_USER=${mysqlUser}/" .env
            sed -i "s/MYSQL_PASSWORD=.*/MYSQL_PASSWORD=${mysqlUserPassword}/" .env
            sed -i "s/MYSQL_DATABASE=.*/MYSQL_DATABASE=${projectName}/" .env
        fi

        # Find an available port
        secure_host_port=1000
        while is_port_in_use $secure_host_port; do
            ((secure_host_port++))
        done

        # Update .env with the found port
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s/HOST_MACHINE_SECURE_HOST_PORT=.*/HOST_MACHINE_SECURE_HOST_PORT=${secure_host_port}/" .env
        else
            sed -i "s/HOST_MACHINE_SECURE_HOST_PORT=.*/HOST_MACHINE_SECURE_HOST_PORT=${secure_host_port}/" .env
        fi

        # Find the next available port for HOST_MACHINE_PMA_SECURE_PORT
        pma_port=$((secure_host_port + 1))
        while is_port_in_use $pma_port; do
            ((pma_port++))
        done

        # Update .env with the found port for HOST_MACHINE_PMA_SECURE_PORT
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s/HOST_MACHINE_PMA_SECURE_PORT=.*/HOST_MACHINE_PMA_SECURE_PORT=${pma_port}/" .env
        else
            sed -i "s/HOST_MACHINE_PMA_SECURE_PORT=.*/HOST_MACHINE_PMA_SECURE_PORT=${pma_port}/" .env
        fi
        ;;
    *)
        echo "Invalid input"
        exit 1
        ;;
esac

# Update .env with the project name
if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "s/COMPOSE_PROJECT_NAME=.*/COMPOSE_PROJECT_NAME=${projectName}/" .env
else
    sed -i "s/COMPOSE_PROJECT_NAME=.*/COMPOSE_PROJECT_NAME=${projectName}/" .env
fi

echo "Configuration completed. Your port number is ${secure_host_port}"
