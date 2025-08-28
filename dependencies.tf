data "external" "git_repo" {
  count = local.input.source_repo_tags_enabled ? 1 : 0

  program = ["sh", "-c", <<-EOF
    # Get git remote URL
    URL=$(git config --get remote.origin.url 2>/dev/null)
    URL_STATUS=$?
    
    # Get current commit hash
    COMMIT=$(git rev-parse HEAD 2>/dev/null)
    COMMIT_STATUS=$?
    
    # Check if both commands succeeded
    if [ $URL_STATUS -eq 0 ] && [ $COMMIT_STATUS -eq 0 ] && [ -n "$URL" ]; then
      # Escape special characters for JSON
      ESCAPED_URL=$(printf '%s' "$URL" | sed 's/"/\\"/g')
      ESCAPED_COMMIT=$(printf '%s' "$COMMIT" | sed 's/"/\\"/g')
      
      # Output JSON with both URL and commit
      echo "{\"url\": \"$ESCAPED_URL\", \"commit\": \"$ESCAPED_COMMIT\"}"
    else
      # Return error if either command failed
      ERR_MSG="Failed to get git information"
      echo "{\"error\": \"$ERR_MSG\"}"
    fi
  EOF
  ]
  working_dir = path.root
}
