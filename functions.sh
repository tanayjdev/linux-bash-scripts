#!/bin/bash

# Greeting function
greet_user() {
    local USERNAME=$1

    echo "Hello, $USERNAME!"
    echo "Welcome to the server"
}

# Service check function
check_service() {
    local SERVICE=$1

    if systemctl is-active --quiet "$SERVICE"; then
        echo "$SERVICE: RUNNING"
    else
        echo "$SERVICE: NOT RUNNING"
    fi
}

# Function calls
greet_user "Tanay"

echo "---"

check_service "ssh"
check_service "nginx"
check_service "docker"
