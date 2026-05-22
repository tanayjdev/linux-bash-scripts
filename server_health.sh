#!/bin/bash

# ================================================
# Server Health Check Script
# ================================================

# ---------- COLORS ----------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ---------- THRESHOLDS ----------
CPU_THRESHOLD=80
RAM_THRESHOLD=80
DISK_THRESHOLD=80

# ================================================
# SECTION 1 — SYSTEM INFO
# ================================================

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE} SERVER HEALTH CHECK REPORT ${NC}"
echo -e "${BLUE}================================================${NC}"

echo "Date: $(date '+%Y-%m-%d %H:%M:%S')"
echo "Hostname: $(hostname)"
echo "OS: $(cat /etc/os-release | grep PRETTY_NAME | cut -d'"' -f2)"
echo "Uptime: $(uptime -p)"
echo "Logged in users: $(who | wc -l)"

echo ""

# ================================================
# SECTION 2 — CPU CHECK
# ================================================

echo -e "${BLUE}--- CPU Usage ---${NC}"

CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1 | cut -d',' -f1)

CPU_INT=${CPU_USAGE%.*}

echo "CPU Usage: $CPU_USAGE%"

if [ "$CPU_INT" -gt "$CPU_THRESHOLD" ] 2>/dev/null; then
    echo -e "${RED} WARNING: CPU usage is HIGH (${CPU_USAGE}%)${NC}"
else
    echo -e "${GREEN} CPU is OK (${CPU_USAGE}%)${NC}"
fi

echo ""

# ================================================
# SECTION 3 — RAM CHECK
# ================================================

echo -e "${BLUE}--- Memory Usage ---${NC}"

TOTAL_RAM=$(free -m | awk '/^Mem:/{print $2}')
USED_RAM=$(free -m | awk '/^Mem:/{print $3}')
FREE_RAM=$(free -m | awk '/^Mem:/{print $4}')

RAM_PERCENT=$((USED_RAM * 100 / TOTAL_RAM))

echo "Total RAM: ${TOTAL_RAM}MB"
echo "Used RAM: ${USED_RAM}MB"
echo "Free RAM: ${FREE_RAM}MB"
echo "RAM Usage: ${RAM_PERCENT}%"

if [ "$RAM_PERCENT" -gt "$RAM_THRESHOLD" ]; then
    echo -e "${RED} WARNING: RAM usage is HIGH (${RAM_PERCENT}%)${NC}"
else
    echo -e "${GREEN} RAM is OK (${RAM_PERCENT}%)${NC}"
fi

echo ""

# ================================================
# SECTION 4 — DISK CHECK
# ================================================

echo -e "${BLUE}--- Disk Usage ---${NC}"

df -h | grep -v tmpfs | grep -v udev | tail -n +2 | while read LINE
do
    PARTITION=$(echo $LINE | awk '{print $6}')
    USAGE=$(echo $LINE | awk '{print $5}' | tr -d '%')
    SIZE=$(echo $LINE | awk '{print $2}')
    USED=$(echo $LINE | awk '{print $3}')
    AVAIL=$(echo $LINE | awk '{print $4}')

    echo "Partition: $PARTITION | Size: $SIZE | Used: $USED | Available: $AVAIL | Usage: $USAGE%"

    if [ "$USAGE" -gt "$DISK_THRESHOLD" ]; then
        echo -e "${RED} WARNING: $PARTITION disk usage is HIGH (${USAGE}%)${NC}"
    fi
done

echo ""

# ================================================
# SECTION 5 — SERVICES CHECK
# ================================================

echo -e "${BLUE}--- Services Status ---${NC}"

SERVICES=("ssh" "nginx" "docker")

for SERVICE in "${SERVICES[@]}"
do
    if systemctl is-active --quiet "$SERVICE" 2>/dev/null; then
        echo -e "${GREEN} $SERVICE: RUNNING${NC}"
    else
        echo -e "${RED} $SERVICE: NOT RUNNING${NC}"
    fi
done

echo ""

# ================================================
# SECTION 6 — NETWORK CHECK
# ================================================

echo -e "${BLUE}--- Network Connectivity ---${NC}"

if ping -c 1 google.com &>/dev/null; then
    echo -e "${GREEN} Internet: CONNECTED${NC}"
else
    echo -e "${RED} Internet: NOT CONNECTED${NC}"
fi

echo "IP Address: $(hostname -I | awk '{print $1}')"

echo ""

# ================================================
# SECTION 7 — SUMMARY
# ================================================

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE} SUMMARY ${NC}"
echo -e "${BLUE}================================================${NC}"

echo "CPU Usage: ${CPU_USAGE}%"
echo "RAM Usage: ${RAM_PERCENT}%"

echo "Check completed at: $(date '+%H:%M:%S')"

echo -e "${BLUE}================================================${NC}"
