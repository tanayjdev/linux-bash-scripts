#!/bin/bash

echo "=== Fruits ==="

for FRUIT in apple banana mango; do
 echo "Fruit: $FRUIT"
done

for i in {1..5}; do
 echo $i
done

COUNT=1

while [ $COUNT -le 5 ]; do
 echo $COUNT
 COUNT=$((COUNT + 1))
done
