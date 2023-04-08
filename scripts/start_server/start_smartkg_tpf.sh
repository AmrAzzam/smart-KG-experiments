#!/bin/bash

# Starts the smartkg/tpf server

# Set the number of clients expected to connect (only needed for the resource monitoring script)
CLIENTS=80
CONFIGFILE=/config-watdiv100.json
WATDIV="100M"

# Delete memory cache
sync; echo 3 > /proc/sys/vm/drop_caches
java -jar /Server.Java/target/ldf-server.jar $CONFIGFILE &
exppid=$!
# Start resource monitoring
python3 /Server.Java/target/monitor.py $exppid $CLIENTS-clients-$WATDIV
wait $exppid
sync; echo 3 > /proc/sys/vm/drop_caches
