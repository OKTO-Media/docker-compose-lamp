#!/usr/bin/env bash

rm docker-compose.yml
cp sample.env .env
read -p "What is the project name? " projectName
read -p "Is this a static site? (Y/N): " isStatic

is_port_in_use() {
    netstat -tuln | grep ":$1 " > /dev/null
}

# Using case-insensitive match for bash and zsh compatibility
case "$isStatic" in
    [Yy])
        # If it's a static site, remove MySQL and PMA related lines
        # Determine if we're on macOS and adjust `sed` command accordingly
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' '/MYSQL_/d' .env
            sed -i '' '/HOST_MACHINE_PMA_SECURE_PORT/d' .env
        else
            sed -i '/MYSQL_/d' .env
            sed -i '/HOST_MACHINE_PMA_SECURE_PORT/d' .env
        fi

        # Copy and Rename static-compose.yml to docker-compose.yml
        cp static-compose.yml docker-compose.yml

        secure_host_port=1000
        while is_port_in_use $secure_host_port; do
            ((secure_host_port++))
        done

        sed -i '' "s/HOST_MACHINE_SECURE_HOST_PORT=.*/HOST_MACHINE_SECURE_HOST_PORT=${secure_host_port}/" .env
        ;;
    [Nn])
        read -p "Enter MySQL User: " mysqlUser
        read -p "Enter MySQL Password: " mysqlUserPassword

        # Copy and Rename static-compose.yml to docker-compose.yml
        cp cms-compose.yml docker-compose.yml

        mysqlRootPassword=$(openssl rand -base64 12)

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
        ;;
    *)
        echo "Invalid input"
        exit 1
        ;;
esac

sed -i '' "s/COMPOSE_PROJECT_NAME=.*/COMPOSE_PROJECT_NAME=${projectName}/" .env

echo "Configuration completed. Your port number is ${secure_host_port}"
