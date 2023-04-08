#!/bin/bash

# Starts the smartkg/tpf server

# Set the number of clients expected to connect (only needed for the resource monitoring script)
CLIENTS=80
WATDIV="100M"

# Delete memory cache
sync; echo 3 > /proc/sys/vm/drop_caches
export PATH=$PATH:/usr/local/virtuoso-opensource/bin/
virtuoso-t -f &
exppid=$!
# Start resource monitoring
python3 /usr/local/virtuoso-opensource/var/lib/virtuoso/db/monitor.py $exppid $CLIENTS-clients-$WATDIV
wait $exppid
sync; echo 3 > /proc/sys/vm/drop_caches
