#!/bin/bash
set -e

echo "=============================================="
echo " Starting Playwright MCP + noVNC"
echo "=============================================="
echo "MCP Port:   ${MCP_PORT:-3000}"
echo "Browser:    ${MCP_BROWSER:-chromium}"
echo "Display:    ${DISPLAY:-:99}"
echo "Resolution: ${SCREEN_WIDTH:-1920}x${SCREEN_HEIGHT:-1080}"
echo "Profile:    /data/adobe-profile"
echo "=============================================="

# -------------------------------------------------
# Xvfb
# -------------------------------------------------

echo "[1/5] Starting Xvfb..."

Xvfb "${DISPLAY:-:99}" \
    -screen 0 "${SCREEN_WIDTH:-1920}x${SCREEN_HEIGHT:-1080}x${SCREEN_DEPTH:-24}" \
    -ac \
    +extension GLX \
    +render \
    -noreset &

XVFB_PID=$!

sleep 2

# -------------------------------------------------
# Fluxbox
# -------------------------------------------------

echo "[2/5] Starting Fluxbox..."

fluxbox \
    -display "${DISPLAY:-:99}" \
    >/tmp/fluxbox.log 2>&1 &

FLUXBOX_PID=$!

sleep 2

# -------------------------------------------------
# x11vnc
# -------------------------------------------------

echo "[3/5] Starting x11vnc..."

x11vnc \
    -display "${DISPLAY:-:99}" \
    -forever \
    -shared \
    -nopw \
    -rfbport 5900 \
    -quiet \
    >/tmp/x11vnc.log 2>&1 &

X11VNC_PID=$!

sleep 2

# -------------------------------------------------
# noVNC
# -------------------------------------------------

echo "[4/5] Starting noVNC..."

websockify \
    --web /usr/share/novnc \
    6080 \
    localhost:5900 \
    >/tmp/novnc.log 2>&1 &

NOVNC_PID=$!

sleep 2

# -------------------------------------------------
# Cleanup
# -------------------------------------------------

cleanup() {
    echo "Stopping services..."

    kill "${NOVNC_PID}" 2>/dev/null || true
    kill "${X11VNC_PID}" 2>/dev/null || true
    kill "${FLUXBOX_PID}" 2>/dev/null || true
    kill "${XVFB_PID}" 2>/dev/null || true
}

trap cleanup EXIT INT TERM

# -------------------------------------------------
# Playwright MCP
# -------------------------------------------------

echo "[5/5] Starting Playwright MCP..."

exec node /app/cli.js \
    --port "${MCP_PORT:-3000}" \
    --host 0.0.0.0 \
    --browser "${MCP_BROWSER:-chromium}" \
    --config /etc/playwright-config.json \
    --allowed-hosts "*" \
    --viewport-size "${SCREEN_WIDTH:-1920}x${SCREEN_HEIGHT:-1080}" \
    --user-data-dir /data/adobe-profile
