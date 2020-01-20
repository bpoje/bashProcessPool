# Bash process pool

Execute multiple commands using process pool in bash.

## Example:

You can run sleep example in:
```
./processpoolp-test.sh
```

It will execute three commands using two processes at the same time.
* "sleep 1"
* "sleep 2"
* "sleep 3"

First sleep 1 and sleep 2 will be executed. Script will wait for both jobs (fist block) to finish and store their exit codes. First block will execute in 2 seconds.
Then sleep 3 will be executed in second block and will finish in 3 seconds.
Total execution time will be approximately 5 seconds.
Exit codes are returned from script processpoolp.sh to test script processpoolp-test.sh using a temporary file.

## As command:
You can run processpoolp.sh directly. Executing sleep example:
```
A_CMD=("sleep 1" "sleep 2" "sleep 3")

./processpoolp.sh ./exitcodes 2 "${A_CMD[@]}"

cat exitcodes 
	0 0 0
```


