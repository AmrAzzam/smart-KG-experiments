#!/bin/bash

# Start TPF Clients

# Delete cached memory
sync; echo 3 > /proc/sys/vm/drop_caches
# Start the experiment and save the results to a text file
tpf/start_tpf_exp.sh &> $HOSTNAME-tpf-1000M-Amr.txt
sync; echo 3 > /proc/sys/vm/drop_caches

