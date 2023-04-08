#!/bin/bash
# Run experiments for Sage
# https://github.com/sage-org/sage-experiments/tree/master/scripts


QUERIES=$1 # i.e. a folder that contains SPARQL queries to execute
OUTPUT=$2
cpt=1

CLIENTS=80
WATDIV="100M"

if [ "$#" -ne 2 ]; then
  echo "Illegal number of parameters."
  echo "Usage: ./run_bgp.sh <queries-directory> <output-folder>"
  exit
fi

SERVER="http://server:8080/sparql/watdiv"

mkdir -p $OUTPUT
mkdir -p $OUTPUT/results/
mkdir -p $OUTPUT/errors/

RESFILE="${OUTPUT}/execution_times_sage.csv"

# init results file with headers
echo "query,time,httpCalls,serverTime,importTime,exportTime,errors" > $RESFILE

for qfile in $QUERIES/*; do
  x=`basename $qfile`
  qname="${x%.*}"
  # query name
  echo -n "${qname}," >> $RESFILE
  # execution time
  # Set timeout here
  timeout 5m /sage-jena-1.1/bin/sage-jena $SERVER -f $qfile -m $RESFILE > /dev/null 2> ${OUTPUT}/errors/${qname}.err &
  timepid=$!
  exppid=$(pgrep -P $timepid)  
  # Resource usage monitoring
  python3 /sage-jena-1.1/bin/monitor.py $exppid Amr-$CLIENTS-clients-$WATDIV 2>/dev/null
  echo -n "," >> $RESFILE
  # nb errors during query processing
  echo `wc -l ${OUTPUT}/errors/${qname}.err | awk '{print $1}'` >> $RESFILE
done

# remove tmp folders
rm -rf $OUTPUT/errors/ $OUTPUT/results/
