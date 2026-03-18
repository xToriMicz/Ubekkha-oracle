# Dashboard Metrics — Ubekkha Monitoring

## Core Metrics to Track

### 1. Uptime Percentage
- **Target**: 99.9% (8.7h downtime/year max)
- **Measurement**: (total_checks - failed_checks) / total_checks × 100
- **Display**: Monthly rolling percentage, trend line
- **Alert threshold**: < 99.5%

### 2. Response Time
- **Metrics**:
  - p50 (median) — typical user experience
  - p95 — worst case for most users
  - p99 — tail latency
- **Target**: p95 < 500ms, p99 < 2000ms
- **Display**: Time series chart, 15-min buckets

### 3. Error Rate
- **Metrics**:
  - 4xx rate — client errors (bad requests, auth failures)
  - 5xx rate — server errors (bugs, overload)
- **Target**: 5xx rate < 0.1%
- **Display**: Stacked area chart, errors by type

### 4. SSL Certificate Status
- **Metrics**: Days until expiry
- **Target**: Always > 30 days (auto-renew)
- **Display**: Single number with color (green > 30d, yellow > 7d, red < 7d)

## Dashboard Layout

```
┌─────────────────────────────────────────────────┐
│  UPTIME: 99.97%          STATUS: ● Operational  │
├────────────────────┬────────────────────────────┤
│  Response Time     │  Error Rate               │
│  p50: 120ms        │  4xx: 0.3%                │
│  p95: 340ms        │  5xx: 0.01%               │
│  p99: 890ms        │                           │
├────────────────────┼────────────────────────────┤
│  [Response Time    │  [Uptime Calendar         │
│   Chart - 24h]     │   30 day heatmap]         │
├────────────────────┼────────────────────────────┤
│  SSL Expiry: 62d   │  Last Incident: None      │
│  ● Valid           │  MTTR: n/a                │
└────────────────────┴────────────────────────────┘
```

## Recommended Tools for Dashboards

| Tool | Type | Best for |
|------|------|----------|
| UptimeRobot Status Page | Hosted | Public status page (free) |
| BetterUptime Dashboard | Hosted | Incident timeline + status |
| Grafana + Prometheus | Self-hosted | Full custom dashboards |
| Uptime Kuma | Self-hosted | Simple, clean monitoring UI |

## Data Retention

| Metric | Granularity | Retention |
|--------|-------------|-----------|
| Raw checks | per-minute | 7 days |
| Aggregated (15-min) | 15 minutes | 90 days |
| Daily summary | daily | 1 year |
| Monthly report | monthly | forever |

## Monthly Report Template

Generate on 1st of each month:
- Uptime % for previous month
- Number of incidents + total downtime
- Average response time + trend vs prior month
- SSL certificate status
- Action items for next month
