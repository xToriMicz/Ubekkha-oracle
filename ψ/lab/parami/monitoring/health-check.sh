#!/usr/bin/env bash
# health-check.sh — Endpoint health checker
# Usage: ./health-check.sh <url> [timeout_seconds]
# Returns: status code, response time, SSL expiry days

set -euo pipefail

URL="${1:?Usage: $0 <url> [timeout_seconds]}"
TIMEOUT="${2:-10}"
LOG_DIR="${LOG_DIR:-/tmp/health-check}"
LOG_FILE="$LOG_DIR/health-$(date +%Y%m%d).log"

mkdir -p "$LOG_DIR"

timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# --- HTTP health check ---
http_response=$(curl -s -o /dev/null -w "%{http_code} %{time_total}" \
  --max-time "$TIMEOUT" "$URL" 2>/dev/null) || {
  echo "$timestamp | $URL | DOWN | timeout after ${TIMEOUT}s" | tee -a "$LOG_FILE"
  exit 1
}

status_code=$(echo "$http_response" | awk '{print $1}')
response_time=$(echo "$http_response" | awk '{print $2}')

# --- SSL expiry check (https only) ---
ssl_expiry_days="n/a"
if [[ "$URL" == https://* ]]; then
  host=$(echo "$URL" | sed 's|https://||;s|/.*||')
  expiry_date=$(echo | openssl s_client -servername "$host" -connect "$host:443" 2>/dev/null \
    | openssl x509 -noout -enddate 2>/dev/null \
    | sed 's/notAfter=//')
  if [ -n "$expiry_date" ]; then
    if date -j -f "%b %d %T %Y %Z" "$expiry_date" +%s >/dev/null 2>&1; then
      expiry_epoch=$(date -j -f "%b %d %T %Y %Z" "$expiry_date" +%s)
    else
      expiry_epoch=$(date -d "$expiry_date" +%s 2>/dev/null || echo "0")
    fi
    now_epoch=$(date +%s)
    ssl_expiry_days=$(( (expiry_epoch - now_epoch) / 86400 ))
  fi
fi

# --- Determine status ---
status="OK"
alerts=""

if [ "$status_code" -ge 400 ]; then
  status="ERROR"
  alerts="http_${status_code}"
fi

response_ms=$(echo "$response_time" | awk '{printf "%.0f", $1 * 1000}')
if [ "$response_ms" -gt 2000 ]; then
  alerts="${alerts:+$alerts,}slow_response_${response_ms}ms"
fi

if [ "$ssl_expiry_days" != "n/a" ] && [ "$ssl_expiry_days" -lt 7 ]; then
  alerts="${alerts:+$alerts,}ssl_expiry_${ssl_expiry_days}d"
fi

# --- Output ---
result="$timestamp | $URL | $status | HTTP $status_code | ${response_time}s | SSL: ${ssl_expiry_days}d"
if [ -n "$alerts" ]; then
  result="$result | ALERT: $alerts"
fi

echo "$result" | tee -a "$LOG_FILE"

# Exit code: 0 = healthy, 1 = alert
[ -z "$alerts" ] && exit 0 || exit 1
