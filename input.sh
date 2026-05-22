#!/bin/bash

echo "Tell your name:"
read USER_NAME

echo "Tell your age:"
read USER_AGE

echo "---"
echo "Hello $USER_NAME!"
echo "Your age is $USER_AGE years"

read -p "Tell your city: " CITY

echo "You live in $CITY"
