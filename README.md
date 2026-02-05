# Morning Digest 📊

A daily morning digest script that aggregates updates from Bitbucket, Jira, and Git repos into a clean, classic-format report. Designed to work with [Clawdbot](https://github.com/clawdbot/clawdbot) cron jobs but works standalone too.

## Features

- **Bitbucket Integration**: Recent commits and open pull requests
- **Jira Integration**: Updated issues from your projects
- **Local Git Repos**: Optional commit history from local repositories
- **Classic Format**: Clean, readable text output with clear sections
- **Automated Delivery**: Schedule with cron or Clawdbot for daily reports

## Example Output

```
═══════════════════════════════════════════════
    MORNING DIGEST - Wednesday, January 29, 2026
═══════════════════════════════════════════════

━━━ BITBUCKET COMMITS (Last 24h) ━━━
Repository: my-repo
----------------------------------------
  • 01/29 08:30 | John Doe | Fixed login bug
  • 01/28 16:45 | Jane Smith | Added user dashboard

━━━ BITBUCKET PULL REQUESTS ━━━
Repository: my-repo
----------------------------------------
  • PR #42: New feature implementation [OPEN] - Jane Smith
  
━━━ JIRA UPDATES (Last 24h) ━━━
Project: MYPROJ
----------------------------------------
  • MYPROJ-123: Fix authentication issue [In Progress] - John Doe
  • MYPROJ-124: Add new dashboard [To Do] - Jane Smith

═══════════════════════════════════════════════
Generated at: 09:00 AM EST
═══════════════════════════════════════════════
```

## Prerequisites

- `bash`
- `curl`
- `jq`
- Bitbucket workspace with API access
- Jira instance with API access
- (Optional) Local git repositories

## Quick Start

### 1. Download the script

```bash
curl -O https://raw.githubusercontent.com/gianramirez/morning-digest/master/morning-digest.sh
chmod +x morning-digest.sh
```

### 2. Configure credentials

Edit `morning-digest.sh` and fill in these sections:

#### Bitbucket Configuration

```bash
BITBUCKET_WORKSPACE="your-workspace-name"
BITBUCKET_REPOS="repo1,repo2,repo3"  # comma-separated
BITBUCKET_USERNAME="your-email@example.com"
BITBUCKET_APP_PASSWORD="your-app-password"
```

**Generate Bitbucket App Password:**
1. Go to https://bitbucket.org/account/settings/app-passwords/
2. Create new token with **Repositories: Read** permission
3. Copy the generated password

#### Jira Configuration

```bash
JIRA_URL="your-company.atlassian.net"  # without https://
JIRA_PROJECT_KEYS="PROJ1,PROJ2"  # comma-separated
JIRA_EMAIL="your-email@example.com"
JIRA_API_TOKEN="your-api-token"
```

**Generate Jira API Token:**
1. Go to https://id.atlassian.com/manage-profile/security/api-tokens
2. Create API token
3. Copy the generated token

#### Git Repos (Optional)

```bash
GIT_REPOS="/path/to/repo1,/path/to/repo2"  # comma-separated local paths
```

### 3. Test it

```bash
./morning-digest.sh
```

## Scheduling

### Standard Cron

Add to your crontab (`crontab -e`):

```bash
# Run at 9:00 AM every day
0 9 * * * /path/to/morning-digest.sh | mail -s "Morning Digest" you@example.com
```

### Clawdbot Integration

If you're using [Clawdbot](https://github.com/clawdbot/clawdbot):

```bash
clawdbot cron add \
  --name "Morning Digest" \
  --cron "0 9 * * *" \
  --tz "America/New_York" \
  --session isolated \
  --message "Run the morning digest script and deliver the output" \
  --deliver \
  --channel last
```

This will:
- Run at 9:00 AM Eastern Time
- Execute the script
- Deliver results to your last active chat (WhatsApp, Telegram, Discord, etc.)

## Configuration Options

Edit the script to customize:

### Time Window

Change how far back to look (default: 24 hours):

```bash
HOURS_BACK=24  # Change to 48 for 2 days, etc.
```

### Repository/Project Filters

```bash
# Watch specific repos
BITBUCKET_REPOS="frontend,backend,api"

# Watch specific Jira projects
JIRA_PROJECT_KEYS="WEB,MOBILE,API"
```

### Output Location

By default, output goes to `/tmp/morning-digest-YYYYMMDD.txt`. Change this:

```bash
OUTPUT="/path/to/your/digest.txt"
```

## Security Notes

⚠️ **Important:**
- The script stores API credentials in plaintext
- Set proper permissions: `chmod 700 morning-digest.sh`
- Consider using environment variables on shared systems
- Never commit filled credentials to version control

## Troubleshooting

### No data appears

- Verify API credentials are correct
- Check repo/project names match exactly
- Ensure there's activity in the time window
- Run manually to see error messages

### Authentication errors

- Regenerate API tokens if expired
- Verify email matches your Jira/Bitbucket account
- Check workspace/org permissions

### Script fails

```bash
# Check dependencies
which curl jq

# Run with verbose output
bash -x ./morning-digest.sh
```

## Contributing

Pull requests welcome! Areas for improvement:

- Additional integrations (GitLab, Azure DevOps, etc.)
- Output format options (JSON, HTML, Markdown)
- Filtering/search capabilities
- Configuration file support

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Related Projects

- [Clawdbot](https://github.com/clawdbot/clawdbot) - AI assistant with scheduling
- [Bitbucket API Docs](https://developer.atlassian.com/cloud/bitbucket/rest/)
- [Jira API Docs](https://developer.atlassian.com/cloud/jira/platform/rest/v3/)

## Author

Created for use with Clawdbot automation workflows.
