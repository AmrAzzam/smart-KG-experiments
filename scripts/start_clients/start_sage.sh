#!/usr/bin/env bash
#!/bin/bash
# Run experiments for Sage

# Delete memory cache
sync; echo 3 > /proc/sys/vm/drop_caches
start_sage_exp.sh /Queries/ /results-experiment-name
sync; echo 3 > /proc/sys/vm/drop_caches

