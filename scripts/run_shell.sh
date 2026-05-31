#!/bin/bash
# Mars Survival — Docker interactive shell (noVNC, demo format)
#
# From repo root:
#   bash scripts/run_shell.sh
#
# Open http://localhost:6080, then inside the container:
#   ./build/main
#   ./build/main --cli
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE_NAME="${TEAM_DOCKER_IMAGE:-chwoong/team_00_project:0.1.0}"
CONTAINER_NAME="${MARS_SHELL_CONTAINER_NAME:-mars-survival-shell-container}"

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
echo "[host] After the shell prompt appears, run: ./build/main"

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
    
    # Wait for Xvfb socket to be created
    for i in {1..30}; do
      if [ -S /tmp/.X11-unix/X99 ]; then
        break
      fi
      sleep 0.2
    done
    sleep 1

    export SDL_VIDEODRIVER=x11
    export XDG_RUNTIME_DIR=/tmp

    openbox &
    x11vnc -display :99 -forever -shared -rfbport 5900 -nopw &
    /usr/share/novnc/utils/novnc_proxy --vnc localhost:5900 --listen 6080 &

    chmod +x /workspace/build/main || true

    echo ""
    echo "=========================================="
    echo " Container ready."
    echo " Open in browser: http://localhost:6080"
    echo " Then run the app with:"
    echo "   ./build/main"
    echo " CLI mode:"
    echo "   ./build/main --cli"
    echo "=========================================="
    echo ""

    exec bash
  '
