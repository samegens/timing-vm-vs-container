#!/bin/bash

while true; do
  status_code=$(curl -s -o /dev/null -w "%{http_code}" --max-time 0.1 http://localhost:8081/index.html 2>/dev/null)

  if [ "$status_code" = "200" ]; then
    echo "Nginx up and running!"
    exit 0
  fi

  sleep 0.1
done
