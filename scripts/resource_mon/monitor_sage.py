#!/usr/bin/env python3

# Resource monitoring for sage server. 
# We need to monitor the child processes as well here. 

import psutil
import csv
import socket
import sys
import time
import json
from datetime import datetime
import re
from multiprocessing import Process
import multiprocessing
from multiprocessing import Pool

def bytes2human(n):
   # From sample script for psutils
   """
   >>> bytes2human(10000)
   '9.8 K'
   >>> bytes2human(100001221)
   '95.4 M'
   """
   symbols = ('K', 'M', 'G', 'T', 'P', 'E', 'Z', 'Y')
   prefix = {}
   for i, s in enumerate(symbols):
      prefix[s] = 1 << (i + 1) * 10
   for s in reversed(symbols):
      if n >= prefix[s]:
         value = float(n) / prefix[s]
         return '%.2f %s' % (value, s)
   return '%.2f B' % (n)


# PSUtil
def getInfo(processID):
    p = psutil.Process(processID)
    cpu = p.cpu_percent(interval=1)
    # Get memory of parent process first
    ram = p.memory_info().rss
    # Get memory of a worker process. They share most of the memory between each other, hence we measure only one and do not aggregate. 
    worker = psutil.Process(p.children()[0].pid)
    ram += worker.memory_info().rss
    for child in p.children(recursive=True):
        try:
            cpu += child.cpu_percent(interval=1)
        except psutil.NoSuchProcess:
            break
        # Write process info to os.csv
    write_csv_os([(datetime.now().strftime('%Y-%m-%d %H:%M:%S')), cpu, bytes2human(ram)])

def commify3(amount):
    amount = str(amount)
    amount = amount[::-1]
    amount = re.sub(r"(\d\d\d)(?=\d)(?!\d*\.)", r"\1,", amount)
    return amount[::-1]

# Network

def getNetInfo():
    
    # Before
    tot_before = psutil.net_io_counters()
    pnic_before = psutil.net_io_counters(pernic=True)

    interval = 1;
    time.sleep(interval)
    
    tot_after = psutil.net_io_counters()
    pnic_after = psutil.net_io_counters(pernic=True)

    tot_sent = bytes2human(tot_after.bytes_sent)
    tot_recv = bytes2human(tot_after.bytes_recv)

    datenow = (datetime.now().strftime('%Y-%m-%d %H:%M:%S'))

    nic_names = list(pnic_after.keys())
    nic_names.sort(key=lambda x: sum(pnic_after[x]), reverse=True)
    for name in nic_names:
        stats_before = pnic_before[name]
        stats_after = pnic_after[name]
        
        # Specify correct network interface. See the output of "ip link" to get the name of the Ethernet device
        if name == 'ens3':
            tot_interface_sent =  bytes2human(stats_after.bytes_sent)
            tot_interface_recv =  bytes2human(stats_after.bytes_recv)
            upspeed = bytes2human(stats_after.bytes_sent - stats_before.bytes_sent)
            downspeed = bytes2human(stats_after.bytes_recv - stats_before.bytes_recv)

    # Write to net.csv
    write_csv_net([datenow, tot_interface_sent, tot_interface_recv, upspeed, downspeed ])

def write_csv_os(data):
    with open('os_'+socket.gethostname()+"_"+expName+'.csv', 'a+') as outfile:
        writer = csv.writer(outfile)
        writer.writerow(data)

def write_csv_net(data):
    with open('net_'+socket.gethostname()+"_"+expName+'.csv', 'a+') as outfile:
        writer = csv.writer(outfile)
        writer.writerow(data)

if __name__ == '__main__':
    while True:
        # Input Process ID here
        processID = int(sys.argv[1])
        global expName
        expName = sys.argv[2]
        p1 = Process(target=getInfo(processID))
        p1.start()
        p2 = Process(target=getNetInfo())
        p2.start()
        p1.join()
        p2.join()
    
