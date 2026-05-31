#!/bin/bash
# Mars Survival — Docker GUI auto-run (noVNC, demo format)
#
# From repo root (folder with build/, assets/, scripts/):
#   bash scripts/run.sh
#
# Then open: http://localhost:6080
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE_NAME="${TEAM_DOCKER_IMAGE:-chwoong/team_00_project:0.1.0}"
CONTAINER_NAME="${MARS_CONTAINER_NAME:-mars-survival-gui-container}"

if ! command -v docker >/dev/null 2>&1; then
  echo "Error: docker not found. Install Docker Desktop (WSL2 backend) and retry." >&2
  exit 1
fi

ensure_binary() {
  if [[ -x "$ROOT/build/main" ]]; then
    return 0
  fi
  if [[ -x "$ROOT/main" ]]; then
    mkdir -p "$ROOT/build"
    cp "$ROOT/main" "$ROOT/build/main"
    chmod +x "$ROOT/build/main"
    echo "[host] Copied ./main -> ./build/main"
    return 0
  fi
  if [[ -f "$ROOT/Makefile" ]]; then
    echo "[host] ./build/main missing; running make..."
    (cd "$ROOT" && make)
    mkdir -p "$ROOT/build"
    cp "$ROOT/main" "$ROOT/build/main"
    chmod +x "$ROOT/build/main"
    return 0
  fi
  echo "Error: executable not found at $ROOT/build/main" >&2
  echo "  Build in WSL: cd $ROOT && make && mkdir -p build && cp main build/main" >&2
  exit 1
}

ensure_binary

echo "[host] Mounting $ROOT -> /workspace"
echo "[host] Browser GUI: http://localhost:6080"
echo "[host] Press Ctrl+C to stop the container."

docker run --rm -it \
  --platform linux/amd64 \
  -p 127.0.0.1:6080:6080 \
  -p 127.0.0.1:5900:5900 \
  -v "$ROOT:/workspace" \
  -w /workspace \
  --name "$CONTAINER_NAME" \
  "$IMAGE_NAME" \
  bash -c '
    set -euo pipefail
    export DISPLAY=:99

    echo "[container] Installing SDL2 runtime (base image has no SDL2)..."
    apt-get update -qq
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      libsdl2-2.0-0 libsdl2-ttf-2.0-0 libsdl2-image-2.0-0 fonts-nanum \
      >/dev/null
    rm -rf /var/lib/apt/lists/*

    Xvfb :99 -screen 0 1280x800x24 &
    sleep 1

    openbox &
    x11vnc -display :99 -forever -shared -rfbport 5900 -nopw &
    /usr/share/novnc/utils/novnc_proxy --vnc localhost:5900 --listen 6080 &

    chmod +x /workspace/build/main
    exec /workspace/build/main
  '
