#!/bin/bash

set -euo pipefail

# 🎯 Konfiguration
EXT_MEDIA_PATH="${MEDIA:-/lichtkasten/.external}"
STAGING_PATH="/lichtkasten/.tmp/import-from-external-media"
LANDING_PATH="/photoprism/import"
LOG_FILE="/lichtkasten/.logs/import.log"
DRY_RUN="${DRY_RUN:-false}"

# 🔍 Unterstützte Dateiendungen (für RAW + andere)
RAW_EXTENSIONS=("ARW" "DNG" "CR2" "NEF" "RAF" "ORF" "TIFF" "TIF" "JPG" "JPEG")

log() {
  echo "[$(date '+%F %T')] $*" | tee -a "$LOG_FILE"
}

log "📂 Import von $EXT_MEDIA_PATH"
log "🗂 Staging in $STAGING_PATH"
log "📦 Ziel (landing zone): $LANDING_PATH"
log "🔎 Unterstützte Dateitypen: ${RAW_EXTENSIONS[*]}"

if [[ "$DRY_RUN" == "true" ]]; then
  log "🧪 Dry-Run aktiv – es werden keine Daten kopiert oder verschoben."
fi

mkdir -p "$STAGING_PATH" "$LANDING_PATH"

shopt -s nullglob
RAW_FILES=()
for EXT in "${RAW_EXTENSIONS[@]}"; do
  RAW_FILES+=("$EXT_MEDIA_PATH"/*."$EXT")
done

COUNT=0

for RAW_FILE in "${RAW_FILES[@]}"; do
  BASENAME=$(basename "$RAW_FILE")
  NAME="${BASENAME%.*}"
  EXT="${BASENAME##*.}"
  XMP_FILE="$EXT_MEDIA_PATH/$NAME.xmp"

  UUID=$(uuidgen)
  NEW_RAW="$STAGING_PATH/$UUID.${EXT,,}"

  log "🔁 $BASENAME → $(basename "$NEW_RAW")"
  if [[ "$DRY_RUN" != "true" ]]; then
    cp "$RAW_FILE" "$NEW_RAW"
  else
    log "💡 (dry-run) würde kopieren: $RAW_FILE → $NEW_RAW"
  fi

  if [[ -e "$XMP_FILE" ]]; then
    NEW_XMP="$STAGING_PATH/$UUID.xmp"
    if [[ "$DRY_RUN" != "true" ]]; then
      cp "$XMP_FILE" "$NEW_XMP"
    else
      log "💡 (dry-run) würde kopieren: $XMP_FILE → $NEW_XMP"
    fi
  else
    log "⚠️ Keine XMP-Datei für $BASENAME gefunden – wird übersprungen."
  fi

done

if [[ "$DRY_RUN" == "true" ]]; then
  log "✅ DRY-RUN abgeschlossen. Keine Daten wurden verschoben."
  exit 0
fi

log "🚚 Verschiebe Dateien nach $LANDING_PATH …"
FILES=("$STAGING_PATH"/*)
if [[ ${#FILES[@]} -gt 0 ]]; then
  mv "$STAGING_PATH"/* "$LANDING_PATH"
else
  log "📭 Keine Dateien zum Verschieben – staging ist leer."
fi

log "🧠 Starte Photoprism-Import via docker exec …"
docker exec photoprism-landing photoprism mv

log "✅ Import abgeschlossen."
exit 0
