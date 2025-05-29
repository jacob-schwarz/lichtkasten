# Lichtkasten

A Docker-based environment for building, staging and watching changes in your Lichtkasten (lightbox) application.

## Features

- **Multi-profile orchestration** via Docker Compose  
- Separate **production** and **development** workflows  
- **Watcher service** for automatic rebuilds on file changes  
- **Staging** script to move and import files into Photoprism  
- **Makefile** shortcuts for common tasks  
- Configurable via a simple `.env` template  

## Repository Structure

The repository currently contains the following files:  
- `.env.template` – template for environment variables  
- `.gitignore`  
- `Containerfile.watcher` – Dockerfile for the watcher service  
- `Makefile` – shortcuts for build, up/down, restart, profile-based starts, and staging  
- `docker-compose.yml` – main Compose definition with profiles  
- `docker-compose.override.yml` – local-override Compose settings for development  
- `stage.sh` – script to prepare staging (moves files)  
- `watcher.sh` – script to start the file-watcher container  

## Prerequisites

- Docker (Engine & CLI)  
- Docker Compose (v2 plugin recommended)  
- GNU Make  
- Bash shell

## Getting Started

1. **Clone the repo**  
   ```bash
   git clone https://github.com/jacob-schwarz/lichtkasten.git
   cd lichtkasten
   ```

2. **Configure environment**  
   ```bash
   cp .env.template .env
   # Edit .env and set your variables, for example:
   # APP_IMAGE=lichtkasten/app
   # WATCHER_IMAGE=lichtkasten/watcher
   # PHOTOPRISM_HOST=localhost
   # PHOTOPRISM_PORT=2342
   ```

3. **Use Makefile targets**  
   - **Production system** (all profiles, no overrides):  
     ```bash
     make up
     ```
   - **Development system** (with overrides):  
     ```bash
     make dev
     ```
   - **Stop all containers**:  
     ```bash
     make down
     ```
   - **Restart full profile set**:  
     ```bash
     make restart
     ```
   - **Start specific profile** (e.g., archive, landing, tools):  
     ```bash
     make archive
     make landing
     make tools
     ```
   - **Stage files** (move and reimport into Photoprism archive):  
     ```bash
     make stage
     ```
   - **Dry-run staging**:  
     ```bash
     make stage-dry
     ```

## Makefile Commands

| Target        | Description                                                                       |
|---------------|-----------------------------------------------------------------------------------|
| `make up`     | Start the production system (all profiles, no overrides)                         |
| `make dev`    | Start the development system (with overrides)                                     |
| `make down`   | Stop and remove all containers                                                    |
| `make restart`| Restart the full profile set (`down` then `up`)                                   |
| `make archive`| Start only the `archive` profile                                                   |
| `make landing`| Start only the `landing` profile                                                   |
| `make tools`  | Start only the `tools` profile                                                     |
| `make stage`  | Run `stage.sh` and then import moved files into the Photoprism archive            |
| `make stage-dry` | Run `stage.sh` with `--dry-run` (no file moves)                               |

## Scripts

- **`stage.sh`**: Prepares files for staging by moving them; subsequent `photoprism import --move` is executed in the archive container.  
- **`watcher.sh`**: Runs the watcher container to detect source changes via `inotify` and triggers rebuilds.

## Dockerfiles

- **`Containerfile.watcher`**: Based on a minimal image, installs `inotify-tools`, and runs the watch loop for live rebuilds.

## Contributing

1. Fork the repository  
2. Create a feature branch (`git checkout -b feature/my-feature`)  
3. Commit your changes (`git commit -m "Add my feature"`)  
4. Push to your branch (`git push origin feature/my-feature`)  
5. Open a Pull Request

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Author

**Jacob Schwarz** – [GitHub profile](https://github.com/jacob-schwarz)
