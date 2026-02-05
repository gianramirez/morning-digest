#!/bin/bash
# Morning Digest - Bitbucket, Jira, Git Commits
# Runs daily at 9:00 AM ET

set -e

# ============================================
# CONFIGURATION - FILL THESE IN
# ============================================

# Bitbucket
BITBUCKET_WORKSPACE="[your-workspace-name]"
BITBUCKET_REPOS="[repo1,repo2,repo3]"  # comma-separated or leave empty for all
BITBUCKET_USERNAME="[your-email]"
BITBUCKET_APP_PASSWORD="[your-app-password]"  # Generate at: https://bitbucket.org/account/settings/app-passwords/

# Jira
JIRA_URL="[your-company.atlassian.net]"
JIRA_PROJECT_KEYS="[PROJ1,PROJ2]"  # comma-separated
JIRA_EMAIL="[your-email]"
JIRA_API_TOKEN="[your-api-token]"  # Generate at: https://id.atlassian.com/manage-profile/security/api-tokens

# Git Commits (local repos)
GIT_REPOS="[/path/to/repo1,/path/to/repo2]"  # comma-separated local repo paths, or leave empty

# Date range (hours back)
HOURS_BACK=24

# ============================================
# SCRIPT - DO NOT EDIT BELOW
# ============================================

OUTPUT="/tmp/morning-digest-$(date +%Y%m%d).txt"
SINCE=$(date -d "$HOURS_BACK hours ago" -Iseconds)

echo "═══════════════════════════════════════════════" > "$OUTPUT"
echo "    MORNING DIGEST - $(date '+%A, %B %d, %Y')" >> "$OUTPUT"
echo "═══════════════════════════════════════════════" >> "$OUTPUT"
echo "" >> "$OUTPUT"

# ============================================
# BITBUCKET COMMITS
# ============================================
if [[ "$BITBUCKET_WORKSPACE" != "[your-workspace-name]" ]]; then
    echo "━━━ BITBUCKET COMMITS (Last ${HOURS_BACK}h) ━━━" >> "$OUTPUT"
    echo "" >> "$OUTPUT"
    
    IFS=',' read -ra REPOS <<< "$BITBUCKET_REPOS"
    for repo in "${REPOS[@]}"; do
        repo=$(echo "$repo" | xargs)  # trim whitespace
        echo "Repository: $repo" >> "$OUTPUT"
        echo "----------------------------------------" >> "$OUTPUT"
        
        commits=$(curl -s -u "$BITBUCKET_USERNAME:$BITBUCKET_APP_PASSWORD" \
            "https://api.bitbucket.org/2.0/repositories/$BITBUCKET_WORKSPACE/$repo/commits?pagelen=50" \
            | jq -r --arg since "$SINCE" '.values[] | select(.date >= $since) | "  • \(.date | fromdateiso8601 | strftime("%m/%d %H:%M")) | \(.author.raw) | \(.message | split("\n")[0])"')
        
        if [[ -n "$commits" ]]; then
            echo "$commits" >> "$OUTPUT"
        else
            echo "  (no commits)" >> "$OUTPUT"
        fi
        echo "" >> "$OUTPUT"
    done
    echo "" >> "$OUTPUT"
fi

# ============================================
# BITBUCKET PULL REQUESTS
# ============================================
if [[ "$BITBUCKET_WORKSPACE" != "[your-workspace-name]" ]]; then
    echo "━━━ BITBUCKET PULL REQUESTS ━━━" >> "$OUTPUT"
    echo "" >> "$OUTPUT"
    
    IFS=',' read -ra REPOS <<< "$BITBUCKET_REPOS"
    for repo in "${REPOS[@]}"; do
        repo=$(echo "$repo" | xargs)
        echo "Repository: $repo" >> "$OUTPUT"
        echo "----------------------------------------" >> "$OUTPUT"
        
        prs=$(curl -s -u "$BITBUCKET_USERNAME:$BITBUCKET_APP_PASSWORD" \
            "https://api.bitbucket.org/2.0/repositories/$BITBUCKET_WORKSPACE/$repo/pullrequests?state=OPEN" \
            | jq -r '.values[] | "  • PR #\(.id): \(.title) [\(.state)] - \(.author.display_name)"')
        
        if [[ -n "$prs" ]]; then
            echo "$prs" >> "$OUTPUT"
        else
            echo "  (no open PRs)" >> "$OUTPUT"
        fi
        echo "" >> "$OUTPUT"
    done
    echo "" >> "$OUTPUT"
fi

# ============================================
# JIRA ISSUES
# ============================================
if [[ "$JIRA_URL" != "[your-company.atlassian.net]" ]]; then
    echo "━━━ JIRA UPDATES (Last ${HOURS_BACK}h) ━━━" >> "$OUTPUT"
    echo "" >> "$OUTPUT"
    
    IFS=',' read -ra PROJECTS <<< "$JIRA_PROJECT_KEYS"
    for project in "${PROJECTS[@]}"; do
        project=$(echo "$project" | xargs)
        echo "Project: $project" >> "$OUTPUT"
        echo "----------------------------------------" >> "$OUTPUT"
        
        # Updated issues
        jql="project=$project AND updated >= -${HOURS_BACK}h ORDER BY updated DESC"
        issues=$(curl -s -u "$JIRA_EMAIL:$JIRA_API_TOKEN" \
            -H "Accept: application/json" \
            "https://$JIRA_URL/rest/api/3/search?jql=$(echo "$jql" | jq -sRr @uri)&maxResults=50" \
            | jq -r '.issues[] | "  • \(.key): \(.fields.summary) [\(.fields.status.name)] - \(.fields.assignee.displayName // "Unassigned")"')
        
        if [[ -n "$issues" ]]; then
            echo "$issues" >> "$OUTPUT"
        else
            echo "  (no updates)" >> "$OUTPUT"
        fi
        echo "" >> "$OUTPUT"
    done
    echo "" >> "$OUTPUT"
fi

# ============================================
# LOCAL GIT COMMITS
# ============================================
if [[ "$GIT_REPOS" != "[/path/to/repo1,/path/to/repo2]" ]] && [[ -n "$GIT_REPOS" ]]; then
    echo "━━━ LOCAL GIT COMMITS (Last ${HOURS_BACK}h) ━━━" >> "$OUTPUT"
    echo "" >> "$OUTPUT"
    
    IFS=',' read -ra REPOS <<< "$GIT_REPOS"
    for repo in "${REPOS[@]}"; do
        repo=$(echo "$repo" | xargs)
        if [[ -d "$repo/.git" ]]; then
            echo "Repository: $(basename $repo)" >> "$OUTPUT"
            echo "----------------------------------------" >> "$OUTPUT"
            
            cd "$repo"
            commits=$(git log --all --since="$HOURS_BACK hours ago" --pretty=format:"  • %ad | %an | %s" --date=format:"%m/%d %H:%M" 2>/dev/null || echo "")
            
            if [[ -n "$commits" ]]; then
                echo "$commits" >> "$OUTPUT"
            else
                echo "  (no commits)" >> "$OUTPUT"
            fi
            echo "" >> "$OUTPUT"
        fi
    done
    echo "" >> "$OUTPUT"
fi

# ============================================
# FOOTER
# ============================================
echo "═══════════════════════════════════════════════" >> "$OUTPUT"
echo "Generated at: $(date '+%I:%M %p %Z')" >> "$OUTPUT"
echo "═══════════════════════════════════════════════" >> "$OUTPUT"

# Output to console (Clawdbot will see this)
cat "$OUTPUT"
