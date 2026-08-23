#!/usr/bin/env bash
set -e
cd ~/playwright-mcp

# Verwaisten docker-proxy auf Port 6080 killen, falls vorhanden
PID=$(sudo ss -tlnp | grep :6080 | grep -oP 'pid=\K[0-9]+' || true)
if [ -n "$PID" ]; then
  echo "Beende verwaisten docker-proxy (PID $PID)..."
  sudo kill -9 "$PID"
  sleep 1
fi

sudo docker compose up -d
sudo docker logs playwright-mcp --tail 20
