.PHONY: up down dev logs clean restart archive landing tools stage stage-dry import-external import-external-dry importer-image

# Produktivsystem starten (alle Profile, keine Overrides)
up:
	@docker compose -f docker-compose.yml --profile "*" up -d

# Devsystem starten (mit Overrides)
dev:
	@docker compose -f docker-compose.yml -f docker-compose.override.yml --profile "*" up -d

# Logs aller Services in Echtzeit anzeigen (Tail 100 Zeilen)
logs:
	@docker compose \
		-f docker-compose.yml \
		-f docker-compose.override.yml \
		--profile "*" \
		logs --follow --tail=100

# Clean runtime data
clean:
	@rm -rf .landing .archive

# Stoppen
down:
	@docker compose -f docker-compose.yml --profile "*" down

# Neustart mit vollem Profil-Set
restart: down up

# Einzelne Profile starten (z. B. make archive)
archive:
	@docker compose -f docker-compose.yml --profile archive up -d

landing:
	@docker compose -f docker-compose.yml --profile landing up -d

tools:
	@docker compose -f docker-compose.yml --profile tools up -d

# Dateien stagen (verschieben und reimportieren)
stage:
	@./stage.sh && docker exec photoprism-archive photoprism import --move

# Dry run für stage
stage-dry:
	@./stage.sh --dry-run

# Importiere Dateien von externem Medium über Container
import-external:
	@docker compose \
		-f docker-compose.yml \
		-f docker-compose.override.yml \
		run --rm \
		-e MEDIA=$(MEDIA) \
		-e DRY_RUN=false \
		importer

# Importiere im DRY-RUN Modus (zum Testen ohne Änderungen)
import-external-dry:
	@docker compose \
		-f docker-compose.yml \
		-f docker-compose.override.yml \
		run --rm \
		-e MEDIA=$(MEDIA) \
		-e DRY_RUN=true \
		importer

importer-image:
	@docker compose build importer
