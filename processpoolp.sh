#!/bin/bash
#Execute multiple commands using process pool in bash
#Author: Blaž Poje
#Usage: ./processpoolp.sh PathToReturnFile ProcsNum CmdArray

if (( $# < 3 )); then
	echo "Wrong number of parameters"
	echo "Usage: $0 PathToReturnFile ProcsNum CmdArray"
	echo ""
	echo "PathToReturnFile: Path to temporary file where exit codes will be stored"
	echo "ProcsNum: Number of processes at once"
	echo "CmdArray: Bash array with commands to be executed in parallel"
	echo ""
	echo "Example:"
	echo "A_CMD=(\"sleep 1\" \"sleep 2\" \"sleep 3\")"
	echo "PROCS_NUM=2"
	echo "RETURN_FILE=\$(mktemp /tmp/process-pool.XXXXXX)"
	echo "processpoolp.sh \$RETURN_FILE \$PROCS_NUM \"\${A_CMD[@]}\""
	echo "cat \"\$RETURN_FILE\""
	echo ""
	exit 1;
fi

RETURN_FILE=$1
NUM_OF_PROC=$2

#Shift script parameters ($3 becomes $1)
shift
shift

#Convert remaining parameters to bash array
A_CMD=("$@")

#Input array length
NUM_OF_RECORDS=${#A_CMD[@]}

#Create empty bash array to store exit codes
A_RESPONSE=()

#Init array A_RESPONSE to -1 for all elements
for ((i=0; i < ${#A_CMD[@]}; i++)) do
	A_RESPONSE[i]=-1
done

#Create empty bash array that will store PIDs
A_PID=()

#Init pid array
for ((i=0; i < $NUM_OF_PROC; i++)); do
	A_PID[i]=-1
done

#Calculate how many blocks (each with selected number of processes) will be necessary to execute every record
# https://stackoverflow.com/questions/2394988/get-ceiling-integer-from-number-in-linux-bash/12536521
NUM_OF_BLOCKS=$(( ($NUM_OF_RECORDS + $NUM_OF_PROC - 1) / $NUM_OF_PROC ))
#echo "NUM_OF_BLOCKS: $NUM_OF_BLOCKS"

#For each block
for ((i=0; i < $NUM_OF_BLOCKS; i++)) do
	#For: all proceses in block AND to the last record in final block
	#start jobs. Command of each job is in RECORD_VALUE.
	for ((j=0; j < $NUM_OF_PROC && $i * $NUM_OF_PROC + j < $NUM_OF_RECORDS; j++)) do
		ID_RECORD=$(( $i * $NUM_OF_PROC + j))
		RECORD_VALUE=${A_CMD[$ID_RECORD]}

		#Fork execution
		sh -c "$RECORD_VALUE" &

		#Get PID of the most recently executed background command
		PID=$!

		#Store pid
		A_PID[j]=$PID
	done

	#For: all processes in block AND to the last record in final block
	#wait for forked jobs to finish and store their exit codes
	for ((j=0; j < $NUM_OF_PROC && $i * $NUM_OF_PROC + j < $NUM_OF_RECORDS; j++)) do
		ID_RECORD=$(( $i * $NUM_OF_PROC + j))

		#Get this process PID
		PID=${A_PID[$j]}

		#Wait for PID to finish
		wait $PID

		#Store exit code
		EXIT_CODE=$?

		#Store exit code to array
		A_RESPONSE[$ID_RECORD]=$EXIT_CODE
	done
done

#Write array with exit codes to temporary file (space separated string)
# https://stackoverflow.com/questions/25291347/how-to-return-an-array-from-a-script-in-bash
printf '%s ' "${A_RESPONSE[@]}" > $RETURN_FILE
