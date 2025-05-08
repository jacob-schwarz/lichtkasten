.PHONY: up down dev restart archive landing tools stage stage-dry

# Produktivsystem starten (alle Profile, keine Overrides)
up:
	@docker compose -f docker-compose.yml --profile "*" up -d

# Devsystem starten (mit Overrides)
dev:
	@docker compose -f docker-compose.yml -f docker-compose.override.yml --profile "*" up -d

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
