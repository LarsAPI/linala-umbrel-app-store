# Optional Productor research browser (proof of concept)

This feature is **opt-in**. The existing `server` service, GHCR image `0.0.79`,
and persistent `/data/adobe-profile` are intentionally unchanged.

## What is included

- A second Compose service (`research`) behind profile `productor`.
- A separate persistent Chromium profile and a separate MCP hostname.
- Chromium startup flags to load an **unpacked** extension from a local volume.
- An independent localhost-only noVNC port (6081).
- A Docker build from this directory for the research service. The stable
  service continues to use the pre-published `0.0.79` image.

**Not included:** Productor binaries, account credentials, a licensed download,
or any guarantee that Productor works inside the pinned Playwright MCP v0.0.79
base image. No automatic Amazon scraping or sales-volume inference is added.

## Before enabling

1. Obtain an authorized copy of Productor that may be run in this environment.
   Do not commit a CRX/unpacked extension, credentials, or cookies to GitHub.
2. On the Umbrel host, place the **unpacked** extension so that the directory
   `${APP_DATA_DIR}/data/extensions/productor/manifest.json` exists.
   `APP_DATA_DIR` means the actual app data directory used by your Umbrel setup;
   do not assume it is the Git checkout directory.
3. Check the extension's permissions and verify its source. An extension may
   access visited pages and should never be installed blindly.
4. Ensure you can build the image from this app directory. Unlike the stable
   service, `research` uses `build: .` and is tagged locally with
   `ghcr.io/larsapi/playwright-mcp-novnc:productor-poc`. Nothing is pushed to GHCR.

## Activate / inspect / stop

Run from the installed `linala-playwright-mcp` Compose directory with
`APP_DATA_DIR` set to the correct Umbrel app-data path:

```sh
test -f "${APP_DATA_DIR}/data/extensions/productor/manifest.json"
docker compose --profile productor config
docker compose --profile productor up -d --build research
docker compose --profile productor logs --tail=100 research
```

The new MCP endpoint is accessible to authorized containers on
`umbrel_main_network` at `http://playwright-mcp-productor:3000/mcp`.
It is **not** published as a public host port. The research service only allows
the `playwright-mcp-productor` Host header. The ordinary MCP endpoint remains
unchanged.

To inspect noVNC, use an SSH tunnel to the Umbrel host, e.g.:

```sh
ssh -L 6081:127.0.0.1:6081 USER@UMBREL_HOST
```

Then open `http://127.0.0.1:6081/vnc.html` locally. noVNC/x11vnc
does not have authentication in the current image: **never publish port 6081
on a non-loopback interface**.

To stop only the research service:

```sh
docker compose --profile productor stop research
```

## Smoke-test before connecting TrendResearcher

1. Start only `research`; confirm the manifest preflight succeeds.
2. Inspect Chromium via noVNC. Verify the extension actually loads.
3. Navigate to a public Amazon US birdwatching-shirt listing. Determine whether
   Productor visibly provides BSR/category information and whether Playwright MCP
   can read that information in its page snapshot or screenshot.
4. Record ASIN, category, BSR, date, and source for each finding. Use
   `UNKNOWN` for absent BSR or estimated sales; **BSR is not an exact sales count**.
5. If Chromium cannot side-load this extension or Productor requires unsupported
   Chrome APIs, leave the research service disabled. Do not change the stable
   Adobe browser to work around it.

Respect Amazon's terms, extension license, and rate limits. Avoid account
login and automated bulk collection during this initial compatibility test.

## Implementation notes

- The existing `start-mcp.sh` defaults are unchanged for the original service.
- Research overrides `MCP_CONFIG`, `MCP_PROFILE_DIR`, `MCP_EXTENSION_DIR`,
  and `MCP_ALLOWED_HOSTS`.
- An extension `manifest.json` is required at startup for research; a missing
  or incorrect bind mount fails explicitly rather than silently running without
  Productor.
- Extension launch uses bundled **Chromium** with a persistent user-data dir;
  Google Chrome and Edge do not support these side-load flags.

Docs: https://playwright.dev/docs/chrome-extensions
