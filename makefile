.PHONY: up down restart landing archive tools stage stage-dry

up:
  @docker compose up -d

down:
  @docker compose down

restart: down
  @docker compose --profile "*" up -d    # startet alle Profile [oai_citation:17‡docs.docker.com](https://docs.docker.com/compose/how-tos/profiles/#:~:text=If%20you%20want%20to%20enable,profile)

landing:
  @docker compose up -d --profile landing

archive:
  @docker compose up -d --profile archive

tools:
  @docker compose up -d --profile tools

stage:
  @./stage.sh

stage-dry:
  @./stage.sh --dry-run
