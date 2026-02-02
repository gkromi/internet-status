#!/bin/bash

HOST="8.8.8.8"        # Host or IP to monitor
INTERVAL=3            # Seconds between checks
TIMEOUT=1             # Ping timeout in seconds
FAIL_THRESHOLD=2      # Consecutive failures before alert
LOGFILE="internet_watch.log"
ALERT_SOUND="internet-down-00.wav"
FAIL_COUNT=0
HOST_DOWN=false

echo "Monitoring $HOST every $INTERVAL seconds..."
echo "Logging to $LOGFILE"
echo "Press Ctrl+C to stop."

while true; do
    if ping -c1 -W"$TIMEOUT" "$HOST" >/dev/null 2>&1; then
        if $HOST_DOWN; then
            echo "$(date '+%F %T') - HOST BACK UP: $HOST" | tee -a "$LOGFILE"
            HOST_DOWN=false
        fi
        FAIL_COUNT=0
    else
        ((FAIL_COUNT++))
        if [ "$FAIL_COUNT" -ge "$FAIL_THRESHOLD" ]; then
            if ! $HOST_DOWN; then
                HOST_DOWN=true
                echo "$(date '+%F %T') - HOST DOWN: $HOST" | tee -a "$LOGFILE"
            fi
            if [ -f "$ALERT_SOUND" ]; then
                aplay -q "$ALERT_SOUND"
            else
                echo -e "\a"
            fi
        fi
    fi
    sleep "$INTERVAL"
done
