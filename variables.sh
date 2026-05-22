#!/bin/bash

NAME="Tanay"
ROLE="DevOps Engineer"
SERVER="EC2"

echo "Name: $NAME"
echo "Role: $ROLE"
echo "Server: $SERVER"

CURRENT_USER=$(whoami)
CURRENT_DATE=$(date +%Y-%m-%d)
DISK_USAGE=$(df -h / | tail -1 | awk '{print $5}')

echo "---"
echo "User: $CURRENT_USER"
echo "Date: $CURRENT_DATE"
echo "Disk usage: $DISK_USAGE"
