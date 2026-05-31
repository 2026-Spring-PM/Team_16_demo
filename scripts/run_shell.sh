#!/bin/bash
# Mars Survival — Docker interactive shell (noVNC + manual run)
# After the container starts, open http://localhost:6080 then run: ./build/main
set -e

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE_NAME="chwoong/team_00_project:0.1.0"
CONTAINER_NAME="mars-survival-gui-container"

docker run --rm -it \
  -p 127.0.0.1:6080:6080 \
  -p 127.0.0.1:5900:5900 \
  -v "$ROOT:/workspace" \
  -w /workspace \
  --name "$CONTAINER_NAME" \
  "$IMAGE_NAME" \
  bash -c '
    set -e
    export DISPLAY=:99

    Xvfb :99 -screen 0 1280x800x24 &
    sleep 1

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
