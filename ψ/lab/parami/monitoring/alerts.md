# Alert Rules — Ubekkha Monitoring

## Critical Alerts (Immediate notification)

### 1. Endpoint Down > 5 minutes
- **Condition**: HTTP status >= 400 or timeout for 5+ consecutive checks
- **Severity**: Critical
- **Action**: Notify via Slack + Email immediately
- **Escalation**: If not acknowledged in 15 min, re-alert

### 2. SSL Certificate Expiry < 7 days
- **Condition**: SSL certificate expires within 7 days
- **Severity**: Critical
- **Action**: Notify via Slack + Email
- **Resolution**: Renew certificate (auto-renew with certbot recommended)

### 3. Response Time > 2 seconds
- **Condition**: Average response time > 2000ms over 3 consecutive checks
- **Severity**: Warning → Critical if sustained > 15 min
- **Action**: Notify via Slack
- **Resolution**: Check server load, database queries, CDN status

## Warning Alerts

### 4. Response Time > 1 second
- **Condition**: Average response time > 1000ms over 5 consecutive checks
- **Severity**: Warning
- **Action**: Log + Slack notification (low priority)

### 5. SSL Certificate Expiry < 30 days
- **Condition**: SSL certificate expires within 30 days
- **Severity**: Warning
- **Action**: Email notification (weekly reminder)

### 6. Error Rate > 5%
- **Condition**: More than 5% of checks return non-2xx in rolling 1-hour window
- **Severity**: Warning → Critical if > 20%
- **Action**: Notify via Slack

## Alert Configuration Template

```yaml
# For UptimeRobot / BetterUptime setup
alerts:
  - name: endpoint-down
    condition: "status != 2xx for 5 minutes"
    severity: critical
    channels: [slack, email]

  - name: slow-response
    condition: "response_time > 2000ms for 3 checks"
    severity: warning
    channels: [slack]

  - name: ssl-expiry
    condition: "ssl_days_remaining < 7"
    severity: critical
    channels: [slack, email]

  - name: high-error-rate
    condition: "error_rate > 5% over 1h"
    severity: warning
    channels: [slack]
```

## Notification Channels

| Channel | Use for | Setup |
|---------|---------|-------|
| Slack | All alerts | Webhook → #monitoring channel |
| Email | Critical only | Direct to on-call |
| Webhook | Automation | POST to incident handler |

## Silence / Maintenance Windows

During planned maintenance:
1. Set maintenance window in monitoring service
2. Suppress alerts for the duration
3. Log maintenance in `ψ/memory/logs/`
4. Verify recovery after maintenance ends
