# Quantitative Finance Atelier

A workspace for learning quantitative finance by doing: notebooks and scripts that work with real market data.

## Principle: Docker only

Nothing is installed on the host except Docker. Python, the libraries, and JupyterLab all live in a container, so the workspace runs the same on any machine with Docker.

## Requirements

- Docker with Compose v2 (`docker compose version`)
- `make`

## Quick start

```bash
make up      # build the image and start JupyterLab
```

Open <http://127.0.0.1:8888/lab>. The Jupyter token is turned off, so the port is bound to `127.0.0.1` and only your own machine can reach it.

```bash
make down    # stop it
```

Run `make` with no arguments to list every command.

## Commands

| Command | What it does |
|---|---|
| `make up` | Build the image and start JupyterLab |
| `make down` | Stop JupyterLab |
| `make restart` | Restart JupyterLab |
| `make logs` | Follow the JupyterLab logs |
| `make shell` | Open a bash shell in the container |
| `make python` | Open a Python REPL |
| `make run SCRIPT=path/to/file.py` | Run a script |
| `make add PKG=name==version` | Add a dependency and rebuild |
| `make remove PKG=name` | Remove a dependency and rebuild |
| `make lock` | Regenerate `uv.lock` from `pyproject.toml` |
| `make build` | Rebuild the image |
| `make clean` | Stop everything and delete the image |

## Dependencies: uv

Dependencies are managed with [uv](https://docs.astral.sh/uv/), a Rust-based Python package and project manager from Astral.

- `pyproject.toml` lists the direct dependencies, each pinned to an exact version.
- `uv.lock` records the full resolved dependency tree. Commit it.
- The image installs from the lock file with `uv sync --locked`, so every build gets the same environment.

To change dependencies, always use `make add` or `make remove`. They run uv in a temporary container, update `pyproject.toml` and `uv.lock`, then rebuild the image. If Lab is already running, run `make restart` to pick up the change. A `pip install` inside a running container is lost the next time the container is recreated.

## Layout

```
.
├── Dockerfile        # uv + Python 3.12 image; installs from uv.lock
├── compose.yaml      # JupyterLab service; mounts this folder at /work
├── Makefile          # every command you need
├── pyproject.toml    # direct dependencies
├── uv.lock           # full resolved dependency tree
├── notebooks/        # Jupyter notebooks
└── data/             # downloaded market data (git-ignored)
```

The project folder is mounted at `/work`, so notebooks and data saved in the container are written straight to your machine. The virtual environment lives at `/opt/venv` inside the image, so the mount cannot hide it.

## Stack

| Library | Version | Role |
|---|---|---|
| Python | 3.12 | Runtime |
| numpy | 2.1.3 | Arrays and linear algebra |
| pandas | 2.2.3 | Time series and tabular data |
| scipy | 1.14.1 | Optimization, statistics, distributions |
| statsmodels | 0.14.4 | Regression and time-series models |
| matplotlib | 3.9.2 | Plotting |
| yfinance | 1.8.0 | Market data from Yahoo Finance |
| jupyterlab | 4.3.0 | Notebook environment |

## References

- uv documentation: <https://docs.astral.sh/uv/>
- Using uv in Docker: <https://docs.astral.sh/uv/guides/integration/docker/>
- yfinance: <https://github.com/ranaroussi/yfinance>
- Docker Compose: <https://docs.docker.com/compose/>

## Changelog

- **2026-11-16**: Initial scaffold. Docker-only workspace, uv for dependencies, Makefile, JupyterLab, yfinance 1.8.0.
