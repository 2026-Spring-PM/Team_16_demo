#!/bin/bash
# Mars Survival — native GUI window (no browser / no noVNC)
#
# WSL2 + Windows 11 (WSLg): opens a normal desktop window on your PC.
#
#   bash scripts/run_window.sh
#
# Optional: force Docker + X11 forward (same window, inside container):
#   USE_DOCKER=1 bash scripts/run_window.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE_NAME="${TEAM_DOCKER_IMAGE:-chwoong/team_00_project:0.1.0}"

ensure_local_binary() {
  cd "$ROOT"
  if [[ -x ./main ]]; then
    return 0
  fi
  if [[ -f ./Makefile ]]; then
    echo "[host] ./main missing; running make..."
    make
    return 0
  fi
  if [[ -x ./build/main ]]; then
    echo "[host] Using ./build/main (demo binary)"
    return 0
  fi
  echo "Error: no executable found in $ROOT (need ./main or ./build/main)" >&2
  exit 1
}

run_local() {
  ensure_local_binary
  cd "$ROOT"

  if [[ -x ./main ]]; then
    BIN="./main"
  else
    BIN="./build/main"
  fi

  if ! ldconfig -p 2>/dev/null | grep -q 'libSDL2-2\.0\.so'; then
    echo "[host] SDL2 runtime not found. Install once:" >&2
    echo "  sudo apt update && sudo apt install -y libsdl2-2.0-0 libsdl2-ttf-2.0-0 libsdl2-image-2.0-0 fonts-nanum" >&2
    exit 1
  fi

  if [[ -z "${DISPLAY:-}" ]] && [[ -z "${WAYLAND_DISPLAY:-}" ]]; then
    echo "Error: no DISPLAY or WAYLAND_DISPLAY." >&2
    echo "  Use WSL2 on Windows 11 (WSLg), or start VcXsrv/X410 and export DISPLAY." >&2
    exit 1
  fi

  echo "[host] Launching $BIN in a native window (cwd: $ROOT)"
  exec "$BIN" "$@"
}

run_docker_x11() {
  if ! command -v docker >/dev/null 2>&1; then
    echo "Error: docker not found." >&2
    exit 1
  fi

  if [[ -z "${DISPLAY:-}" ]]; then
    echo "Error: DISPLAY is not set (required for Docker + X11)." >&2
    echo "  WSL: echo \$DISPLAY   (usually :0 with WSLg)" >&2
    exit 1
  fi

  if [[ ! -x "$ROOT/build/main" ]]; then
    if [[ -x "$ROOT/main" ]]; then
      mkdir -p "$ROOT/build"
      cp "$ROOT/main" "$ROOT/build/main"
      chmod +x "$ROOT/build/main"
    elif [[ -f "$ROOT/Makefile" ]]; then
      (cd "$ROOT" && make)
      mkdir -p "$ROOT/build"
      cp "$ROOT/main" "$ROOT/build/main"
      chmod +x "$ROOT/build/main"
    else
      echo "Error: $ROOT/build/main not found." >&2
      exit 1
    fi
  fi

  X11_ARGS=()
  if [[ -d /tmp/.X11-unix ]]; then
    X11_ARGS+=(-v /tmp/.X11-unix:/tmp/.X11-unix)
  fi
  if [[ -d /mnt/wslg ]]; then
    X11_ARGS+=(-v /mnt/wslg:/mnt/wslg)
    X11_ARGS+=(-e "WAYLAND_DISPLAY=${WAYLAND_DISPLAY:-wayland-0}")
    X11_ARGS+=(-e "XDG_RUNTIME_DIR=${XDG_RUNTIME_DIR:-/mnt/wslg/runtime-dir}")
    X11_ARGS+=(-e "PULSE_SERVER=${PULSE_SERVER:-unix:/mnt/wslg/PulseServer}")
  fi

  echo "[host] Docker + X11 -> DISPLAY=$DISPLAY"
  docker run --rm -it \
    --platform linux/amd64 \
    -e DISPLAY="$DISPLAY" \
    "${X11_ARGS[@]}" \
    -v "$ROOT:/workspace" \
    -w /workspace \
    "$IMAGE_NAME" \
    bash -c '
      set -euo pipefail
      apt-get update -qq
      DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        libsdl2-2.0-0 libsdl2-ttf-2.0-0 libsdl2-image-2.0-0 fonts-nanum \
        >/dev/null
      rm -rf /var/lib/apt/lists/*
      chmod +x /workspace/build/main
      exec /workspace/build/main
    '
}

if [[ "${USE_DOCKER:-0}" == "1" ]]; then
  run_docker_x11 "$@"
else
  run_local "$@"
fi
