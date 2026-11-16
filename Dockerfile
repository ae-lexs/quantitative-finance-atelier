FROM ghcr.io/astral-sh/uv:0.9.5-python3.12-bookworm-slim

# The venv lives outside /work so the bind mount in compose.yaml cannot hide it.
ENV UV_PROJECT_ENVIRONMENT=/opt/venv \
    UV_COMPILE_BYTECODE=1 \
    UV_LINK_MODE=copy \
    PATH="/opt/venv/bin:$PATH"

WORKDIR /work
COPY pyproject.toml uv.lock ./
RUN uv sync --locked --no-install-project

EXPOSE 8888
CMD ["jupyter", "lab", "--ip=0.0.0.0", "--port=8888", "--no-browser", "--allow-root", "--IdentityProvider.token=", "--ServerApp.root_dir=/work"]
