#!/bin/bash
interval=${DIONYSUS_EWW_REFRESH_INTERVAL:-1}

while true; do
  eww update line_refresh=$(date +%s%3N)
  sleep "$interval"
done
