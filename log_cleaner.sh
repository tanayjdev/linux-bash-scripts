#!/bin/bash

# ================================================
# Log Cleaner Script
# ================================================

# ---------- CONFIG ----------
LOG_DIRS=(
 "/home/ubuntu/test_logs"
 "/home/ubuntu/logs"
)

DAYS_TO_KEEP=7
DAYS_TO_COMPRESS=3

REPORT_FILE="/home/ubuntu/logs/cleanup_report_$(date +%Y%m%d_%H%M%S).txt"

# ---------- COLORS ----------
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ================================================
# FUNCTION: LOG REPORT
# ================================================

log_report() {

 echo "[$(date '+%H:%M:%S')] $1" | tee -a $REPORT_FILE
}

# ================================================
# FUNCTION: DIRECTORY SIZE
# ================================================

get_dir_size() {

 local DIR=$1

 du -sh "$DIR" 2>/dev/null | awk '{print $1}'
}

# ================================================
# FUNCTION: DELETE OLD LOGS
# ================================================

delete_old_logs() {

 local DIR=$1
 local DAYS=$2

 echo -e "${BLUE}Deleting logs older than $DAYS days in: $DIR${NC}"

 DELETED_COUNT=0

 while IFS= read -r FILE
 do

  if [ -f "$FILE" ]; then

   echo -e "${RED}Deleting: $(basename $FILE)${NC}"

   rm "$FILE"

   DELETED_COUNT=$((DELETED_COUNT + 1))

   log_report "DELETED: $FILE"

  fi

 done < <(find "$DIR" -type f -name "*.log" -mtime +$DAYS 2>/dev/null)

 echo "Deleted: $DELETED_COUNT files"

 log_report "Deleted $DELETED_COUNT old logs from $DIR"
}

# ================================================
# FUNCTION: COMPRESS LOGS
# ================================================

compress_logs() {

 local DIR=$1
 local DAYS=$2

 echo -e "${BLUE}Compressing logs older than $DAYS days in: $DIR${NC}"

 COMPRESSED_COUNT=0

 while IFS= read -r FILE
 do

  if [ -f "$FILE" ] && [[ "$FILE" != *.gz ]]; then

   echo -e "${YELLOW}Compressing: $(basename $FILE)${NC}"

   gzip "$FILE"

   COMPRESSED_COUNT=$((COMPRESSED_COUNT + 1))

   log_report "COMPRESSED: $FILE"

  fi

 done < <(find "$DIR" -type f -name "*.log" -mtime +$DAYS -mtime -$DAYS_TO_KEEP 2>/dev/null)

 echo "Compressed: $COMPRESSED_COUNT files"

 log_report "Compressed $COMPRESSED_COUNT files in $DIR"
}

# ================================================
# MAIN SCRIPT
# ================================================

mkdir -p /home/ubuntu/logs

echo -e "${BLUE}================================================${NC}"
echo -e "${BLUE} LOG CLEANER SCRIPT ${NC}"
echo -e "${BLUE}================================================${NC}"

echo "Started: $(date)"
echo "Keep logs for: $DAYS_TO_KEEP days"
echo "Compress logs older than: $DAYS_TO_COMPRESS days"

echo ""

log_report "=== Log cleanup started ==="

for DIR in "${LOG_DIRS[@]}"
do

 if [ ! -d "$DIR" ]; then

  echo -e "${YELLOW}Skipping (not found): $DIR${NC}"

  continue

 fi

 echo -e "${BLUE}--- Processing: $DIR ---${NC}"

 SIZE_BEFORE=$(get_dir_size "$DIR")

 echo "Size before: $SIZE_BEFORE"

 delete_old_logs "$DIR" "$DAYS_TO_KEEP"

 compress_logs "$DIR" "$DAYS_TO_COMPRESS"

 SIZE_AFTER=$(get_dir_size "$DIR")

 echo "Size after: $SIZE_AFTER"

 echo ""

 log_report "DIR: $DIR | Before: $SIZE_BEFORE | After: $SIZE_AFTER"

done

# ================================================
# SUMMARY
# ================================================

echo -e "${BLUE}================================================${NC}"

echo -e "${BLUE} SUMMARY ${NC}"

echo -e "${BLUE}================================================${NC}"

echo "Cleanup completed: $(date)"

echo "Report saved: $REPORT_FILE"

log_report "=== Cleanup completed ==="

echo ""

echo "Report contents:"

cat $REPORT_FILE
