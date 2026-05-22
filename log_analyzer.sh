#!/bin/bash

LOG_FILE=${1:-"/home/ubuntu/sample.log"}

echo "================================================"
echo "Log Analysis: $LOG_FILE"
echo "Generated: $(date)"
echo "================================================"

echo ""
echo "--- Summary ---"

echo "Total lines: $(wc -l < $LOG_FILE)"
echo "ERROR count: $(grep -c 'ERROR' $LOG_FILE)"
echo "WARNING count: $(grep -c 'WARNING' $LOG_FILE)"
echo "INFO count: $(grep -c 'INFO' $LOG_FILE)"

echo ""
echo "--- Errors ---"

grep "ERROR" $LOG_FILE | awk '{print NR". "$0}'

echo ""
echo "--- Warnings ---"

grep "WARNING" $LOG_FILE | awk '{print NR". "$0}'

echo ""
echo "--- Hourly distribution ---"

awk '{print $2}' $LOG_FILE | cut -d: -f1 | sort | uniq -c
