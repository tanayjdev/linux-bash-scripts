#!/bin/bash

# ================================================
# Backup Script
# ================================================

# ---------- CONFIGURATION ----------

BACKUP_SOURCES=(
 "/home/ubuntu/important_data"
 "/home/ubuntu/scripts"
)

BACKUP_DEST="/home/ubuntu/backups"

BACKUP_PREFIX="backup"

RETENTION_DAYS=7

LOG_FILE="/home/ubuntu/logs/backup.log"

MAX_BACKUP_SIZE="500M"

# ---------- COLORS ----------

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ================================================
# FUNCTION: LOGGING
# ================================================

log() {

 local LEVEL=$1
 local MESSAGE=$2

 local TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

 echo "[$TIMESTAMP] [$LEVEL] $MESSAGE" | tee -a $LOG_FILE
}

# ================================================
# FUNCTION: CHECK SPACE
# ================================================

check_space() {

 local DEST=$1

 local AVAIL=$(df -BM "$DEST" | tail -1 | awk '{print $4}' | tr -d 'M')

 if [ "$AVAIL" -lt 100 ]; then

  echo -e "${RED}Error: Not enough disk space${NC}"

  log "ERROR" "Insufficient disk space"

  return 1

 fi

 echo -e "${GREEN}Disk space OK: ${AVAIL}MB available${NC}"

 return 0
}

# ================================================
# FUNCTION: VERIFY BACKUP
# ================================================

verify_backup() {

 local BACKUP_FILE=$1

 echo "Verifying backup..."

 tar -tzf "$BACKUP_FILE" &>/dev/null

 if [ $? -eq 0 ]; then

  local FILE_COUNT=$(tar -tzf "$BACKUP_FILE" | wc -l)

  echo -e "${GREEN}Verification passed: $FILE_COUNT files${NC}"

  log "INFO" "Verified: $BACKUP_FILE"

  return 0

 else

  echo -e "${RED}Verification FAILED${NC}"

  log "ERROR" "Verification failed"

  return 1

 fi
}

# ================================================
# FUNCTION: CREATE BACKUP
# ================================================

create_backup() {

 local SOURCE=$1
 local DEST=$2

 local TIMESTAMP=$(date +%Y%m%d_%H%M%S)

 local SOURCE_NAME=$(basename "$SOURCE")

 local BACKUP_FILE="$DEST/${BACKUP_PREFIX}_${SOURCE_NAME}_${TIMESTAMP}.tar.gz"

 echo -e "${BLUE}Backing up: $SOURCE${NC}"

 echo "Destination: $BACKUP_FILE"

 # Source check
 if [ ! -e "$SOURCE" ]; then

  echo -e "${RED}Source not found${NC}"

  log "ERROR" "Source not found: $SOURCE"

  return 1

 fi

 # Create backup
 tar -czf "$BACKUP_FILE" \
  -C "$(dirname $SOURCE)" \
  "$(basename $SOURCE)" \
  2>/dev/null

 if [ $? -ne 0 ]; then

  echo -e "${RED}Backup failed${NC}"

  log "ERROR" "Backup failed: $SOURCE"

  rm -f "$BACKUP_FILE"

  return 1

 fi

 BACKUP_SIZE=$(du -sh "$BACKUP_FILE" | awk '{print $1}')

 echo -e "${GREEN}Backup created: $(basename $BACKUP_FILE) ($BACKUP_SIZE)${NC}"

 log "SUCCESS" "Backup created: $BACKUP_FILE"

 # Verify
 verify_backup "$BACKUP_FILE"

 echo "$BACKUP_FILE"

 return 0
}

# ================================================
# FUNCTION: CLEANUP OLD BACKUPS
# ================================================

cleanup_old_backups() {

 local DEST=$1
 local DAYS=$2

 echo ""
 echo -e "${BLUE}Cleaning backups older than $DAYS days...${NC}"

 DELETED=0

 while IFS= read -r OLD_BACKUP
 do

  echo -e "${YELLOW}Removing: $(basename $OLD_BACKUP)${NC}"

  rm "$OLD_BACKUP"

  DELETED=$((DELETED + 1))

  log "INFO" "Removed old backup: $OLD_BACKUP"

 done < <(find "$DEST" -name "${BACKUP_PREFIX}_*.tar.gz" -mtime +$DAYS 2>/dev/null)

 if [ $DELETED -eq 0 ]; then

  echo "No old backups"

 else

  echo -e "${GREEN}Removed $DELETED old backup(s)${NC}"

 fi
}

# ================================================
# FUNCTION: LIST BACKUPS
# ================================================

list_backups() {

 local DEST=$1

 echo ""
 echo -e "${BLUE}Current backups:${NC}"

 if ls "$DEST"/${BACKUP_PREFIX}_*.tar.gz &>/dev/null; then

  ls -lh "$DEST"/${BACKUP_PREFIX}_*.tar.gz | awk '{print " " $5 "\t" $9}'

  TOTAL=$(du -sh "$DEST" | awk '{print $1}')

  echo "Total size: $TOTAL"

 else

  echo "No backups found"

 fi
}

# ================================================
# MAIN SCRIPT
# ================================================

mkdir -p "$BACKUP_DEST"

mkdir -p /home/ubuntu/logs

echo -e "${BLUE}================================================${NC}"

echo -e "${BLUE} BACKUP SCRIPT ${NC}"

echo -e "${BLUE}================================================${NC}"

echo "Started: $(date)"

echo "Sources: ${#BACKUP_SOURCES[@]}"

echo "Destination: $BACKUP_DEST"

echo "Retention: $RETENTION_DAYS days"

echo ""

log "INFO" "=== Backup started ==="

# Space check
check_space "$BACKUP_DEST"

if [ $? -ne 0 ]; then

 exit 1

fi

echo ""

SUCCESS=0
FAILED=0

# Create backups
for SOURCE in "${BACKUP_SOURCES[@]}"
do

 create_backup "$SOURCE" "$BACKUP_DEST"

 if [ $? -eq 0 ]; then

  SUCCESS=$((SUCCESS + 1))

 else

  FAILED=$((FAILED + 1))

 fi

 echo ""

done

# Cleanup old backups
cleanup_old_backups "$BACKUP_DEST" "$RETENTION_DAYS"

# List backups
list_backups "$BACKUP_DEST"

# Summary
echo ""

echo -e "${BLUE}================================================${NC}"

echo -e "${BLUE} SUMMARY ${NC}"

echo -e "${BLUE}================================================${NC}"

echo -e "${GREEN}Successful backups: $SUCCESS${NC}"

if [ $FAILED -gt 0 ]; then

 echo -e "${RED}Failed backups: $FAILED${NC}"

fi

echo "Completed: $(date)"

echo "Log: $LOG_FILE"

log "INFO" "=== Backup completed ==="
