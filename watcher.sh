#!/bin/bash

IMPORT_DIR="/photoprism/import"
INTERVAL=30

echo "[Watcher] Starte Überwachung von $IMPORT_DIR alle $INTERVAL Sekunden..."

while true; do
  shopt -s nullglob
  FILES=("$IMPORT_DIR"/*)
  if (( ${#FILES[@]} > 0 )); then
    echo "[Watcher] ${#FILES[@]} Datei(en) erkannt – starte Import..."

    RESPONSE=$(curl -s -v -u "admin:$PHOTOPRISM_ADMIN_PASSWORD" \
      -H "Content-Type: application/json" \
      -X POST "http://photoprism-landing:2342/api/v1/import/" \
      -d '{}')

    echo "[Watcher] Photoprism antwortete: $RESPONSE"
  else
    echo "[Watcher] Keine neuen Dateien."
  fi

  sleep $INTERVAL
done