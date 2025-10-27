#!/usr/bin/env python3
import os
import time
import logging
import sys
import json
from urllib.parse import quote_plus

import requests

# --- Config -------------------------------------------------------------------
SF_INSTANCE_URL = os.getenv("SF_INSTANCE_URL", "").strip()
API_VERSION = "v59.0"
SOQL = "SELECT Id,Name,Industry,BillingCity,BillingCountry FROM Account LIMIT 10"
INTERVAL_SECONDS = 30
TIMEOUT_SECONDS = 10

# --- Logging ------------------------------------------------------------------
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s %(levelname)s %(message)s",
    stream=sys.stdout,
)
log = logging.getLogger("sf-no-auth-poller")

# --- Helpers ------------------------------------------------------------------
def build_url(SF_INSTANCE_URL: str) -> str:
    soql_qs = quote_plus(SOQL, safe=", *")
    return (
        f"https://{SF_INSTANCE_URL}"
        f"/services/data/{API_VERSION}/query/?q={soql_qs}"
    )

def next_tick_scheduler(interval: float):
    start = time.monotonic()
    n = 0
    while True:
        yield start + n * interval
        n += 1

def is_json_response(resp: requests.Response) -> bool:
    ctype = (resp.headers.get("Content-Type") or "").lower()
    # Treat as JSON if declared, or if body *looks* like JSON
    if "application/json" in ctype:
        return True
    text = (resp.text or "").lstrip()
    return text.startswith("{") or text.startswith("[")

# --- Main loop ----------------------------------------------------------------
def main():
    if not SF_INSTANCE_URL:
        log.warning("ENV var SF_INSTANCE_URL is empty. Set SF_INSTANCE_URL to your org subdomain (e.g., 'example').")

    ticker = next_tick_scheduler(INTERVAL_SECONDS)
    for target in ticker:
        now = time.monotonic()
        if target > now:
            time.sleep(target - now)

        if not SF_INSTANCE_URL:
            log.error("Missing SF_INSTANCE_URL; skipping request this cycle.")
            continue

        url = build_url(SF_INSTANCE_URL)

        try:
            resp = requests.get(
                url,
                headers={
                    "Accept": "application/json",
                },
                timeout=TIMEOUT_SECONDS,
                allow_redirects=False,
            )

            ctype = resp.headers.get("Content-Type", "?")
            log.info("GET %s -> %s %s (Content-Type: %s, Length: %s)",
                     url, resp.status_code, resp.reason, ctype, resp.headers.get("Content-Length", "?"))

            # Non-JSON bodies: keep very small to avoid HTML dumps
            # body = (resp.text or "")
            # if body:
            #     snippet = body if len(body) <= 400 else body[:400] + "…"
            #     print(snippet)

            # Flush immediately so you see output each cycle
            sys.stdout.flush()

        except Exception as e:
            log.error("Request error: %s", e)

if __name__ == "__main__":
    import signal
    signal.signal(signal.SIGINT, signal.SIG_IGN)  # ignore Ctrl+C (never exits requirement)
    main()
