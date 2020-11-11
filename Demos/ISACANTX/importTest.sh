#!/bin/bash

if [ -z $1 ]; then
  echo "Please specify an input file"
  exit 1
fi

while read line; do
  echo $line
  echo $line | nc -N 10.50.7.50 2003
done <$1
