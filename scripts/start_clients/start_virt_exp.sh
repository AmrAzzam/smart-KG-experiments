#!/bin/bash
# Run execution time experiment for virtuoso
# https://github.com/sage-org/sage-experiments/tree/master/scripts


QUERIES=$1 # i.e. a folder that contains SPARQL queries to execute
OUTPUT=$2
cpt=1

CLIENTS=80
WATDIV="100M"

if [ "$#" -ne 2 ]; then
  echo "Illegal number of parameters."
  echo "Usage: ./run_virtuoso.sh <queries-directory> <output-folder>"
  exit
fi

SERVER="http://server:8080/sparql/"

mkdir -p $OUTPUT/results/
mkdir -p $OUTPUT/errors/

RESFILE="${OUTPUT}/execution_times_virtuoso.csv"

# init results file with headers
echo "query,time,httpCalls,nbResults,errors" > $RESFILE

for qfile in $QUERIES/*; do
  x=`basename $qfile`
  qname="${x%.*}"
  echo -n "${qname}," >> $RESFILE
  # execution time
  # Set timeout here
  timeout 5m virtuoso.js $SERVER -f $qfile -m $RESFILE > /dev/null 2> $OUTPUT/errors/$qname.err &
  timepid=$!
  exppid=$(pgrep -P $timepid)
  # Start resource usage monitoring
  python3 monitor.py $exppid Virtuoso-Amr-$CLIENTS-clients-$WATDIV 2>/dev/null
  # nb results
  echo -n "," >> $RESFILE
  # nb errors during query processing
  echo `wc -l ${OUTPUT}/errors/${qname}.err | awk '{print $1}'` >> $RESFILE
done

# remove tmp folders
rm -rf $OUTPUT/errors/

