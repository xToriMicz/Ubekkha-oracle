# Uptime Monitoring — Service Recommendations

## Free Tier Options

### 1. UptimeRobot (Recommended for start)
- **URL**: https://uptimerobot.com
- **Free tier**: 50 monitors, 5-min interval
- **Alert channels**: Email, Slack, Webhook, Telegram
- **Setup**:
  1. Create account
  2. Add HTTP(s) monitor → paste endpoint URL
  3. Set check interval to 5 minutes
  4. Add alert contact (email + Slack webhook)
- **Why**: Simple, reliable, generous free tier

### 2. BetterUptime (Better dashboards)
- **URL**: https://betteruptime.com
- **Free tier**: 10 monitors, 3-min interval
- **Alert channels**: Email, Slack, SMS, Phone call
- **Setup**:
  1. Create account
  2. Add monitor → HTTP keyword or heartbeat
  3. Set up on-call schedule (even solo)
  4. Create public status page (free)
- **Why**: Status pages + incident management built-in

### 3. Uptime Kuma (Self-hosted)
- **URL**: https://github.com/louislam/uptime-kuma
- **Free**: Fully free, self-hosted
- **Alert channels**: 90+ notification services
- **Setup**:
  ```bash
  docker run -d --restart=always -p 3001:3001 \
    -v uptime-kuma:/app/data \
    --name uptime-kuma louislam/uptime-kuma:1
  ```
- **Why**: Full control, no vendor lock-in, great UI

## Recommended Starting Setup

For Ubekkha's monitoring needs:

1. **UptimeRobot** for external endpoint monitoring (free, 5-min checks)
2. **health-check.sh** via cron for detailed local checks (1-min interval)
3. Optional: **Uptime Kuma** if self-hosting is preferred

### Cron Setup for health-check.sh

```bash
# Check every minute, log results
* * * * * /path/to/health-check.sh https://your-endpoint.com >> /var/log/health-check.log 2>&1

# Daily summary at 9am
0 9 * * * grep "ALERT" /tmp/health-check/health-$(date +\%Y\%m\%d).log | mail -s "Health Alert Summary" your@email.com
```
