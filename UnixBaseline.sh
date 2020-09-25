#!/bin/bash

#gather the hostname of the system into a variable called HOST
HOST=$(hostname)
echo "Audit profile for $HOST:"
echo "========================================"
echo -n "Distribution version is:"
#Grab the desc of the linux release and remove any leading spaces
lsb_release -d | awk -F: '/Desc/ {print $2}' | sed -e 's/^[\t ]//g'
echo
echo "IPv4 addresses on this system:"
ip a | awk '/inet[^6]/ {print $2}'
echo
echo "Profiling sytemctl startup scripts:"
echo
systemctl list-unit-files | awk '/enabled[ ]*$/ {print $1}'
echo
echo "Profiling INIT-style startup scripts:"
echo
#get the runlevel of the system (startup scripts)
RL=$(who -r | awk '{print $2}')
echo "Detected INIT runlevel of $RL"
echo
DIR="/etc/rc$RL.d"
ls -H -l $DIR
