FROM mcr.microsoft.com/playwright/mcp:v0.0.79

USER root

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:99
ENV SCREEN_WIDTH=1920
ENV SCREEN_HEIGHT=1080
ENV SCREEN_DEPTH=24
ENV MCP_PORT=3000
ENV MCP_BROWSER=chromium
ENV HOME=/root

RUN apt-get update && apt-get install -y \
    xvfb \
    x11vnc \
    novnc \
    websockify \
    fluxbox \
    dbus-x11 \
    wget \
    procps \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p /data/adobe-profile \
    /var/log/playwright \
    /tmp/playwright

# Chromium muss in diesem Container ohne Sandbox laufen.
# Headed mode wird über Xvfb bereitgestellt.
RUN cat > /etc/playwright-config.json <<'EOF'
{
  "browser": {
    "launchOptions": {
      "headless": false,
      "args": [
        "--no-sandbox",
        "--disable-dev-shm-usage",
        "--disable-infobars"
      ]
    }
  }
}
EOF

COPY playwright-productor-config.json /etc/playwright-productor-config.json
COPY start-mcp.sh /usr/local/bin/start-mcp.sh
RUN chmod +x /usr/local/bin/start-mcp.sh

EXPOSE 3000 6080 5900

ENTRYPOINT ["/usr/local/bin/start-mcp.sh"]
