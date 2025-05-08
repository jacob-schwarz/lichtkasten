.PHONY: up dev down restart stage stage-dry clean logs

# Basis-Compose-Dateien (Produktion)
COMPOSE_BASE = -f docker-compose.landing.yml \
               -f docker-compose.archive.yml \
               -f docker-compose.tools.yml

# Entwicklung (Basis + Overrides)
COMPOSE_DEV  = $(COMPOSE_BASE) -f docker-compose.override.yml

# ——————————————————  Ziele  ——————————————————

# Produktion starten (ohne Overrides)
up:
	docker compose $(COMPOSE_BASE) up -d

# Entwicklung starten (mit Overrides)
dev:
	docker compose $(COMPOSE_DEV) up -d

# Container stoppen (nutzt DEV-Stack; für Prod → down-prod anlegen)
down:
	docker compose $(COMPOSE_DEV) down

# Logs aller Container verfolgen
logs:
	docker compose $(COMPOSE_DEV) logs -f

# Dateien mit Label 'keep' in Archiv verschieben
stage:
	@echo "→ Staging Dateien mit Tag 'keep'..."
	SRC=.landing/original DST=.archive/import ./stage.sh
	@echo "→ Reimportiere in Archiv-Instanz..."
	docker exec photoprism-archive photoprism import --move

# Trockenlauf – nichts wird verschoben
stage-dry:
	./stage.sh --dry-run

# Aufräumen lokaler Hilfsdateien
clean:
	rm -f stage.log keeper.list

# Neustart (Entwicklung)
restart: down dev
