#!/bin/bash
# Start smartkg client

# Remove previously downloaded partitions
rm -f /root/infobiz/smartkg/Client.Java/downloadedPartitions/*

java -jar /smartkg/Client.Java/target/smartKG-client-jar-with-dependencies.jar ConfigurationFiles/config.json &
exppid=$!
# Start resource usage monitoring. Experiment name passed to monitoring script from config.json
python3 monitor.py $exppid ConfigurationFiles/config.json
wait $exppid

# Clean downloaded partitions
rm -f /root/infobiz/smartkg/Client.Java/downloadedPartitions/*
