# Morning Digest - Setup Instructions

This folder contains a daily morning digest script that pulls from Bitbucket, Jira, and Git commits.

## What it does

Every morning at 9:00 AM ET, you'll get a classic-format digest with:
- Bitbucket commits (last 24 hours)
- Bitbucket pull requests (open PRs)
- Jira updates (last 24 hours)
- Local git commits (if configured)

## Files

- **morning-digest.sh** - Main script with placeholder config
- **README.md** - This file

## Configuration (Fill these in at work!)

Edit `morning-digest.sh` and replace the following placeholders:

### Bitbucket Configuration

```bash
BITBUCKET_WORKSPACE="[your-workspace-name]"
BITBUCKET_REPOS="[repo1,repo2,repo3]"  # comma-separated
BITBUCKET_USERNAME="[your-email]"
BITBUCKET_APP_PASSWORD="[your-app-password]"
```

**To generate a Bitbucket App Password:**
1. Go to https://bitbucket.org/account/settings/app-passwords/
2. Click "Create app password"
3. Give it a label (e.g., "Morning Digest")
4. Select permissions: **Repositories: Read**
5. Copy the password (you can't see it again!)

### Jira Configuration

```bash
JIRA_URL="[your-company.atlassian.net]"  # without https://
JIRA_PROJECT_KEYS="[PROJ1,PROJ2]"  # comma-separated
JIRA_EMAIL="[your-email]"
JIRA_API_TOKEN="[your-api-token]"
```

**To generate a Jira API Token:**
1. Go to https://id.atlassian.com/manage-profile/security/api-tokens
2. Click "Create API token"
3. Give it a label (e.g., "Morning Digest")
4. Copy the token

### Git Commits (Optional)

```bash
GIT_REPOS="[/path/to/repo1,/path/to/repo2]"  # comma-separated local paths
```

If you want to include local git repo commits, add the full paths here. Leave empty if you don't need this.

## Schedule

The digest runs every morning at **9:00 AM Eastern Time**.

To view or manage the cron job:
```bash
clawdbot cron list
clawdbot cron runs --id f8eec110-f612-451b-b194-41aa8b37f339
```

To manually test the script:
```bash
/root/clawd/scripts/morning-digest.sh
```

To force-run the cron job now:
```bash
clawdbot cron run f8eec110-f612-451b-b194-41aa8b37f339 --force
```

## Output Format

The digest uses a "classic" format with clear sections:

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
...

━━━ JIRA UPDATES (Last 24h) ━━━
...

═══════════════════════════════════════════════
Generated at: 09:00 AM EST
═══════════════════════════════════════════════
```

## Troubleshooting

**Nothing shows up:**
- Check that you've filled in the configuration placeholders
- Verify your API tokens are valid
- Run the script manually to see error messages

**Some sections are empty:**
- Normal if there's no activity in the last 24 hours
- Check the repo/project names are correct

**Script fails:**
- Make sure `jq` and `curl` are installed
- Check your API credentials
- Verify network access to Bitbucket/Jira

## Security Note

This script stores API credentials in plaintext. Make sure:
- The script has appropriate permissions: `chmod 700 morning-digest.sh`
- Only you can read the file
- Consider using environment variables if this is on a shared system

## Need Changes?

Edit the script to:
- Change the time window (default: 24 hours)
- Add/remove repos or projects
- Modify the output format
- Filter specific types of updates
