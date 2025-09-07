#!/usr/bin/env bash
export PATH=/usr/bin:/bin:/usr/local/bin


rotate_logs() {
	find "$LOGS_DIR" -name "*.log" -mtime +7 -exec gzip {} \;
	find "$LOGS_DIR" -name "*.log.gz" -mtime +30 -exec rm {} \;
}

insert_db() {

    HOST=$(hostname)
    CPU=$(echo "$OUTPUT" | jq '.cpu')
    MEM=$(echo "$OUTPUT" | jq '.mem')
    DISK=$(echo "$OUTPUT" | jq '.disk')

    mariadb -D monitor_db -e \
        "INSERT INTO metrics (hostname, timestamp, cpu_usage, mem_usage, disk_usage) \
        VALUES ('$HOST', NOW(), $CPU, $MEM, $DISK);"
}

compile_and_run() {

    TIMESTAMP=$(date +%F_%T)

    if ! g++ "$FILE" -o "$EXEC_FILE"; then
        echo "[$TIMESTAMP] Compilation failed" >> "$LOG_FILE"
        exit 1
    fi

    echo "[$TIMESTAMP]" >> "$LOG_FILE"

    OUTPUT=$("$EXEC_FILE" 2>> "$LOG_FILE") #2>> redirects stderr to log file, $() redirects stdout to OUTPUT
    echo "$OUTPUT" >> "$LOG_FILE"
    
    insert_db
}

main() {

    DIR="$HOME/GitHub/NetSysSuite"
    LOGS_DIR="$DIR/logs"
    mkdir -p "$LOGS_DIR"

    LOG_FILE="$LOGS_DIR/$(date +%F).log"
    EXEC_FILE="$DIR/src/execute"
    FILE="$DIR/src/daemon.cpp"

    compile_and_run
    rotate_logs
}

main

