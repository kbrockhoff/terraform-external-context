# AI Agent Git Ops – Brockhoff Repos

## Principles

* **Simplicity:** One clear purpose per operation.
* **Composable:** Steps build independently; easy to debug.

## Branch Management

* **Name:** `feature/descriptive-name`, `bugfix/issue-description` (kebab-case, branch from `main`).
* **Stay current:** `make update-branch`; resolve conflicts immediately.

## Commits

* **Pre-commit:** `make pre-commit` if not pushing, `make validate` if pushing.
* **Format:** [Conventional Commits](https://www.conventionalcommits.org/)
  `type(scope): description`
* **Scope:** Atomic, working-state, clear intent (“why”).

## Pull Requests

* **Pre-PR:** `make validate`
* **Template:** Use `.github/pull_request_template.md`

## Quality Gates

* **Automated:** `make validate` (must pass all: format, check, lint, test, docs)
* **Manual review:** Focus on simplicity, decoupling, clarity, and testability

## Troubleshooting

* **Rebase/merge conflicts:** Resolve immediately
* **Test/lint errors:** Fix root cause, don’t mask
* **Reset workspace:**
  `cd $(git rev-parse --show-toplevel) && pwd`
  `git reset --hard origin/main`
  `git clean -fd`
  `make clean`

## AI Agent Commands

* **Validate:** `make validate`
* **Quick check:** `make pre-commit`
* **Info:** `make status`
* **Resource count:** `make resource-count`
* **Cleanup:** `make clean`

**Best Practices:**

* Use single-command Make targets; Fail fast (`make validate`); keep context (`make status`); know rollback (`git reset`, `make clean`).

---

**Tip:** Prefer `make <target>` whenever possible.
