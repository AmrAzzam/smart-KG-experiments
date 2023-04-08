#!/bin/bash
# Start virtuoso clients

WATDIV="100m"

sync; echo 3 > /proc/sys/vm/drop_caches
start-virt_exp.sh Queries results-virtuoso-Amr-$WATDIV
sync; echo 3 > /proc/sys/vm/drop_caches                                       
