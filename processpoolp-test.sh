#!/bin/bash
#Test of executing multiple commands using process pool
#Author: Blaž Poje

#Example:
A_CMD=("sleep 1" "sleep 2" "sleep 3")

#Example:
#A_CMD=( \
#"echo start1 && sleep 1 && echo end1" \
#"echo start2 && sleep 2 && echo end2" \
#"echo start3 && sleep 3 && echo end3" \
#)

#Example:
#A_CMD=("ping -c4 -q 10.15.19.1" "ping -c4 -q 10.15.19.2" "ping -c4 -q 10.15.19.3" "ping -c4 -q 10.15.19.4")

#Display command array
echo "Display cmd array:"
for ((i=0; i < ${#A_CMD[@]}; i++)) do
	echo "index: $i command: ${A_CMD[i]}"
done
echo ""

#Number of processes at once
PROCS_NUM=2

#Create temporary file where exit codes will be stored
RETURN_FILE=$(mktemp /tmp/process-pool.XXXXXX)
echo "File with exit codes: $RETURN_FILE"

#Execute with process pool
./processpoolp.sh $RETURN_FILE $PROCS_NUM "${A_CMD[@]}"

#Read exit codes
VALUE_FROM_CALL=$(cat "$RETURN_FILE")

#Convert space separated string to array
A_EC=($VALUE_FROM_CALL)

#Display array
echo "Display exit codes:"
for ((i=0; i < ${#A_EC[@]}; i++)) do
	echo "index: $i exit code: ${A_EC[i]}"
done
echo ""

#Remove temporary file
#rm "$RETURN_FILE"
