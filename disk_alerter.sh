#!/bin/bash

# ================================================
# Disk Usage Alerter Script
# ================================================

# ---------- CONFIGURATION ----------
THRESHOLD=80

LOG_FILE="/home/ubuntu/logs/disk_alert.log"

ALERT_FILE="/home/ubuntu/logs/disk_alerts_$(date +%Y%m%d).txt"

# ---------- COLORS ----------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ---------- CREATE LOG DIRECTORY ----------
mkdir -p /home/ubuntu/logs

# ================================================
# FUNCTION: LOG MESSAGE
# ================================================

log_message() {

    local MESSAGE=$1

    local TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

    echo "[$TIMESTAMP] $MESSAGE" | tee -a $LOG_FILE
}

# ================================================
# FUNCTION: CHECK PARTITION
# ================================================

check_partition() {

    local PARTITION=$1
    local USAGE=$2
    local SIZE=$3
    local USED=$4
    local AVAIL=$5

    if [ "$USAGE" -gt "$THRESHOLD" ]; then

        echo -e "${RED} ALERT: $PARTITION is at ${USAGE}% (Used: $USED / Total: $SIZE)${NC}"

        log_message "ALERT: $PARTITION at ${USAGE}% - Used: $USED, Available: $AVAIL"

        echo "PARTITION: $PARTITION" >> $ALERT_FILE
        echo "USAGE: ${USAGE}%" >> $ALERT_FILE
        echo "USED: $USED / $SIZE" >> $ALERT_FILE
        echo "TIME: $(date)" >> $ALERT_FILE
        echo "---" >> $ALERT_FILE

        return 1

    else

        echo -e "${GREEN} $PARTITION: ${USAGE}% used (${USED}/${SIZE}) — OK${NC}"

        log_message "OK: $PARTITION at ${USAGE}%"

        return 0

    fi
}

# ================================================
# MAIN SCRIPT
# ================================================

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE} DISK USAGE ALERTER ${NC}"
echo -e "${BLUE}================================================${NC}"

echo "Threshold: ${THRESHOLD}%"
echo "Time: $(date '+%Y-%m-%d %H:%M:%S')"
echo "Hostname: $(hostname)"

echo ""

log_message "=== Disk check started ==="

ALERT_COUNT=0

while IFS= read -r LINE
do

    PARTITION=$(echo "$LINE" | awk '{print $6}')

    USAGE=$(echo "$LINE" | awk '{print $5}' | tr -d '%')

    SIZE=$(echo "$LINE" | awk '{print $2}')

    USED=$(echo "$LINE" | awk '{print $3}')

    AVAIL=$(echo "$LINE" | awk '{print $4}')

    [ -z "$PARTITION" ] && continue
    [ -z "$USAGE" ] && continue

    check_partition "$PARTITION" "$USAGE" "$SIZE" "$USED" "$AVAIL"

    if [ $? -eq 1 ]; then
        ALERT_COUNT=$((ALERT_COUNT + 1))
    fi

done < <(df -h | grep -v tmpfs | grep -v udev | grep -v Filesystem)

echo ""

# ================================================
# SUMMARY
# ================================================

echo -e "${BLUE}--- Summary ---${NC}"

if [ $ALERT_COUNT -gt 0 ]; then

    echo -e "${RED} $ALERT_COUNT partition(s) need attention!${NC}"

    echo -e "${RED} Check: $ALERT_FILE${NC}"

    log_message "SUMMARY: $ALERT_COUNT alerts generated"

else

    echo -e "${GREEN} All partitions are within threshold (${THRESHOLD}%)${NC}"

    log_message "SUMMARY: All partitions OK"

fi

echo ""

echo "Log saved to: $LOG_FILE"

log_message "=== Disk check completed ==="
