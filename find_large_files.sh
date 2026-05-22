#!/bin/bash

# ================================================
# Find Large Files Script
# ================================================

SEARCH_DIR=${1:-"/"}

SIZE_THRESHOLD=${2:-"100M"}

OUTPUT_FILE="/home/ubuntu/logs/large_files_$(date +%Y%m%d).txt"

echo "Searching for files larger than $SIZE_THRESHOLD in $SEARCH_DIR"

echo "This may take a moment..."

sudo find $SEARCH_DIR \
    -type f \
    -size +$SIZE_THRESHOLD \
    -not -path "*/proc/*" \
    -not -path "*/sys/*" \
    2>/dev/null \
| xargs ls -lh 2>/dev/null \
| sort -k5 -rh \
| head -20 \
| tee $OUTPUT_FILE

echo ""

echo "Results saved to: $OUTPUT_FILE"
