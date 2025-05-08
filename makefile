.PHONY: up down restart stage stage-dry clean

# Container starten
up:
	docker compose -f docker-compose.landing.yml -f docker-compose.archive.yml -f docker-compose.tools.yml -f docker-compose.override.yml up -d

# Container stoppen
down:
	docker compose -f docker-compose.landing.yml -f docker-compose.archive.yml -f docker-compose.tools.yml -f docker-compose.override.yml down

# Verschiebe akzeptierte Dateien in das Archiv
stage:
	@echo "→ Staging Dateien mit Tag 'keep'..."
	SRC=.landing/original DST=.archive/import ./stage.sh
	@echo "→ Reimportiere in Archiv-Instanz..."
	docker exec photoprism-archive photoprism import --move

# Nur simulieren, nichts verschieben
stage-dry:
	./stage.sh --dry-run

# Alles aufräumen (nur lokale Daten, keine Medien!)
clean:
	rm -f stage.log keeper.list
restart: down up
