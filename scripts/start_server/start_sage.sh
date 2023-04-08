#!/bin/bash

# Starts the sage server

# Set the number of clients expected to connect (only needed for the resource monitoring script)
CLIENTS=80
CONFIGFILE=/home/amr/sage-engine/config100M.yaml
WATDIV="100M"

# Delete memory cache
sync; echo 3 > /proc/sys/vm/drop_caches
/usr/local/bin/sage $CONFIGFILE -w 4 -p 8080 &
exppid=$!
# Wait for workers to come up and then start the resource monitoring script
sleep 10
python3 /home/amr/sage-engine/monitor.py $exppid $CLIENTS-clients-$WATDIV
wait $exppid
sync; echo 3 > /proc/sys/vm/drop_caches
