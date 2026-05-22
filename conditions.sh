#!/bin/bash

NUMBER=10

if [ $NUMBER -gt 5 ]; then
 echo "$NUMBER is bigger than 5"

elif [ $NUMBER -eq 5 ]; then
 echo "$NUMBER is equal to 5"

else
 echo "$NUMBER is less than 5"
fi
