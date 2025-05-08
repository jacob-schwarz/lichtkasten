#!/bin/bash

# Konfiguration
SRC=".landing/originals"
DST=".archive/import"
DB_CONTAINER="mariadb-landing"
DB_NAME="photoprism"
DB_USER="photoprism"
DB_PASS="photopass"
LABEL="keep"
DRY_RUN=false
LOGFILE="stage.log"

# Dry-Run aktivieren
if [[ "$1" == "--dry-run" ]]; then
  DRY_RUN=true
  echo "[DRY RUN] Kein echtes Verschieben, nur Vorschau." | tee -a "$LOGFILE"
fi

echo "=== STAGE START: $(date) ===" >> "$LOGFILE"

# Hole Liste aller markierten Dateien mit vollständigem Namen
docker exec "$DB_CONTAINER" \
  mysql -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" \
  -e "SELECT files.file_name FROM photos \
      JOIN photos_labels ON photos.id = photos_labels.photo_id \
      JOIN labels ON photos_labels.label_id = labels.id \
      JOIN files ON photos.photo_uid = files.photo_uid \
      WHERE labels.label_name = '$LABEL';" \
  | tail -n +2 > keeper.list

# Verarbeite jede Datei
while read -r relpath; do
  src="$SRC/$relpath"
  dst="$DST/$relpath"

  if [ -f "$src" ]; then
    echo "Staging: $relpath" | tee -a "$LOGFILE"

    if [ "$DRY_RUN" = false ]; then
      mkdir -p "$(dirname "$dst")"
      mv "$src" "$dst" && echo "Moved: $src -> $dst" >> "$LOGFILE"
      if [ -f "$src.xmp" ]; then
        mv "$src.xmp" "$dst.xmp" && echo "Moved XMP: $src.xmp -> $dst.xmp" >> "$LOGFILE"
      fi
    fi
  else
    echo "SKIPPED (not found): $relpath" | tee -a "$LOGFILE"
  fi
done < keeper.list

rm keeper.list
echo "=== STAGE END: $(date) ===" >> "$LOGFILE"