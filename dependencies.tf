data "external" "git_repo" {
  count = local.input.source_repo_tags_enabled ? 1 : 0

  program     = ["sh", "-c", "U=$(git config --get remote.origin.url 2>/dev/null); STATUS=$?; if [ $STATUS -eq 0 ] && [ -n \"$U\" ]; then ESCAPED_U=$(printf '%s' \"$U\" | sed 's/\"/\\\\\"/g'); echo \"{\\\"url\\\": \\\"$ESCAPED_U\\\"}\"; else ERR_MSG=\"Failed to get git remote URL\"; echo \"{\\\"error\\\": \\\"$ERR_MSG\\\"}\"; fi"]
  working_dir = path.root
}
