#!/usr/bin/env bash
export PATH=/usr/bin:/bin:/usr/local/bin


rotate_logs() {
	find "$LOGS_DIR" -name "*.log" -mtime +7 -exec gzip {} \;
	find "$LOGS_DIR" -name "*.log.gz" -mtime +30 -exec rm {} \;
}

compile_and_run() {

    TIMESTAMP=$(date +%F_%T)

    if ! g++ "$FILE" -o "$EXEC_FILE"; then
        echo "[$TIMESTAMP] Compilation failed" >> "$LOG_FILE"
        exit 1
    fi

    echo "[$TIMESTAMP]" >> "$LOG_FILE"

    "$EXEC_FILE" >> "$LOG_FILE" 2>&1

}

main() {

    DIR="$HOME/GitHub/NetSysSuite"
    LOGS_DIR="$DIR/logs"
    mkdir -p "$LOGS_DIR"

    LOG_FILE="$LOGS_DIR/$(date +%F).log"
    EXEC_FILE="$DIR/execute"
    FILE="$DIR/daemon.cpp"

    compile_and_run
    rotate_logs
}

main

