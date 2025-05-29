#!/bin/bash

IMPORT_DIR="/photoprism/import"
INTERVAL=30

echo "[Watcher] Starte Überwachung von $IMPORT_DIR alle $INTERVAL Sekunden..."

while true; do
  shopt -s nullglob
  FILES=("$IMPORT_DIR"/*)
  if (( ${#FILES[@]} > 0 )); then
    echo "[Watcher] ${#FILES[@]} Datei(en) erkannt – starte Import..."

    RESPONSE=$(
      curl -s -v \
        -H "Authorization: Bearer WJXcfs-3UfHv6-yDlJyI-5vVGMa" \
        -H "Content-Type: application/json" \
        -X POST "http://photoprism-landing:2342/api/v1/import/" \
        -d '{"move": true}'
      )

    echo "Photoprism antwortete: $RESPONSE"
  else
    echo "[Watcher] Keine neuen Dateien."
  fi

  sleep $INTERVAL
done