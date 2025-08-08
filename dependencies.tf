data "external" "git_repo" {
  count = local.input.source_repo_tags_enabled ? 1 : 0

  program     = ["sh", "-c", "U=`git config --get remote.origin.url`; echo \"{\\\"url\\\": \\\"$U\\\"}\""]
  working_dir = path.root
}
