#!/bin/bash

# Start running tpf experiments

# Iterate over queries

CLIENTS=80
WATDIV="100M"

for i in Queries/*; do
    [ -f "$i" ] || break
    echo -n $i | awk '{print $NF}' FS=/
    time timeout 30m /root/infobiz/tpf/bin/ldf-client http://server:8080/watdiv $i >/dev/null &
    exppid=$(pgrep node)
    # Start resource usage monitoring
    python3 monitor.py $exppid Amr-$CLIENTS-clients-$WATDIV 2>/dev/null
done

