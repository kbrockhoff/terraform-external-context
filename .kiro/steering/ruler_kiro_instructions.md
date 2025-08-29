

<!-- Source: .ruler/AGENTS.md -->

# Brockhof Cloud Context Terraform Module Guide for AI Agents

What the goal of this module is.

## Components

### Context
- Provides name prefix standardization with output value named `named_prefix`
- Provides standardized/consistent tags/labels with output values named `tags` and `data_tags`
- Support AWS, Azure, and GCP naming and tagging conventions

### Naming
- Name prefix compilies with the Brockhoff Terraform module standard expected by all modules.
  - Regex: `/^[a-z][a-z0-9-]{0,22}[a-z0-9]$/`
- Name can be inputted one of two ways:
  - `namespace`, `name`, and `environment` variables joined with a hyphen.
  - `name` variable only which is used only if `namespace` and `environment` are not provided.



<!-- Source: .ruler/brockhoff-git.md -->

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



<!-- Source: .ruler/terraform-module.md -->

# Terraform Module Guide for AI Agents

## Core Principles

* **One Responsibility:** Each module should have a single, clear purpose.
* **Composition over Configuration:** Build focused modules that work together, not all-in-one solutions.
* **Minimal, Predictable Interfaces:** Expose only essential variables and outputs. Avoid leaking implementation details.
* **Fail Fast:** Validate inputs and stop early on errors.
* **Clear Documentation:** Explain purpose, usage, and design decisions.

## Module Design

**Good Examples:**

```hcl
# Single-purpose modules
module "vpc" { source = "./modules/vpc" name = var.name cidr_block = var.cidr }
module "db" { source = "./modules/rds" name = "${var.name}-db" subnets = module.vpc.db_subnets }
```

**Avoid:**

```hcl
module "monolith" { create_vpc = true; create_db = true; create_lb = true; ... }
```

## Interfaces

* **Inputs:** Only what's needed; group related config in objects; use sensible defaults and validation.
* **Feature Flags:** Use booleans for optional resources.
* **Outputs:** Only what's useful for composition—IDs, endpoints, etc.
  *Don’t expose internal resource details.*

## Patterns

* **Consistent Naming & Tagging:** Use predictable names and common tags.
* **Version Pinning:** Lock Terraform and provider versions in `versions.tf`.
* **Centralize Data Sources:** Place all external data lookups in one file and pass results to submodules.

## File Structure

```
/main.tf           # Core logic
/variables.tf      # Inputs
/outputs.tf        # Outputs
/locals.tf         # Computed values
/versions.tf       # Version constraints
/dependencies.tf   # Data sources
/examples/         # Usage demos
/modules/          # Optional submodules
/test/             # Automated tests
```

## AWS Best Practices

* Use `aws_iam_policy_document` instead of inline JSON for policies.
* Default to encryption with customer-managed KMS.
* Create log groups explicitly.

## Avoid

* **God Modules:** Don’t build modules that do everything.
* **Too Many Inputs:** Limit options; use environment-based defaults.
* **Implicit Dependencies:** Accept IDs as inputs, not naming assumptions.
* **Tight Coupling:** Modules shouldn’t assume other modules’ structure.

## Documentation & Testing

* Provide clear examples and rationale in `README.md`.
* Use `terraform-docs` for reference docs.
* Ensure modules are easily testable (`terraform plan` with example configs).

## Release & CI/CD

* Tag releases on `main` with semantic versioning.
* Use GitHub Actions (or similar) to run format, validate, and test steps automatically.

## AI Agent Checklist

* [ ] Single responsibility & clear purpose
* [ ] Minimal, validated inputs and meaningful outputs
* [ ] Predictable naming/tagging
* [ ] Centralized external dependencies
* [ ] Example configs and docs provided
* [ ] Tested for `plan` success and edge cases

---

**Summary:**
Favor small, focused modules with clear interfaces and strong defaults. Compose modules for complex scenarios. Document intent and usage. Avoid monolithic, over-configured designs. **Simplicity and clarity beat feature-completeness.**



<!-- Source: .ruler/terraform-style.md -->

# Terraform Style Guide for AI Agents

*Based on the [Gruntwork](https://docs.gruntwork.io/guides/style/terraform-style-guide/) and [HashiCorp](https://developer.hashicorp.com/terraform/language/style) guides. Focus: simple, reasoning-friendly infrastructure.*

## Core Principles

* **Choose simple over easy:** Each component should have one clear responsibility; prefer clarity over shortcuts.
* **Explicit over implicit:** Make all dependencies and resource relationships obvious.
* **Localize change:** Changes should not require understanding distant code.
* **Composition over configuration:** Build small, independent modules with clear interfaces and minimal assumptions.

## Understanding Terraform Behavior

* Be able to answer:

  * What will be created?
  * In what order?
  * What changes if a variable changes?
  * What external dependencies exist?
* Make dependencies explicit (avoid hidden dependencies through naming/data sources).
* Ensure changes to variables affect only what is expected.

## Design Patterns

* **Module boundaries:** Each module should have a single reason to change (e.g., VPC, compute).
* **Interface design:** Use variables/outputs to define clear, minimal contracts.
* **Data flow:** Ensure values flow in one direction and are derived in locals when needed.

## Syntax and Style

* **Formatting:** Enforced by `terraform fmt` (2-space indent, 120-char lines, blank lines between resources, trailing newline).
* **Naming:** Use `snake_case` and descriptive names with consistent prefixes.
* **Comments:** Use `#` for comments, `----` for section headers, and always explain non-obvious code.
* **Variables:** Always provide descriptions and types; prefer explicit objects over free-form maps; add validation as needed.

## Avoiding Complexity

* **No implicit dependencies:** Reference resources directly, not by naming convention.
* **Avoid nested conditionals:** Use locals to simplify boolean logic.
* **No magic values:** Use variables and data sources, not hardcoded strings or numbers.
* **Single-purpose modules:** Avoid modules overloaded with flags for optional features.

## AI Agent Guidelines

* **Prioritize:** Reasoning clarity, localized change, explicit dependencies, clean interfaces, correct syntax.
* **Generate self-explanatory code:** Comment rationale for settings and explain resource decisions.
* **When refactoring:** Preserve behavior, extract complexity to locals, make dependencies explicit, and clarify logic.
* **Testing:** Verify behavioral correctness, dependency resolution, and predictable change impact.

---

**Remember:** Simple code enables reliable change and long-term maintainability.



<!-- Source: .ruler/terraform-test.md -->

# Terraform Test Guide for AI Agents

## Testing Philosophy

* **Test the module contract**: Focus on configuration, planning, outputs, and edge cases—not cloud provider itself.
* **Simple over comprehensive**: One concern per test; avoid brittle “cover everything” tests.
* **Plan-only preferred**: Validate `terraform plan` outputs, not real cloud provider state (avoid unnecessary costs).

## Test Design

* **Single responsibility**: One aspect per test (e.g., defaults, feature flags).
* **Clear failures**: Assertions should explain what’s wrong.
* **Test independence**: Use unique names and don’t share state.
* **Focus on essentials**: Test desired behaviors, not implementation details.

## Repository Organization

* **modules/**: Terraform modules
* **examples/**: Minimal (`defaults/`), full (`complete/`) and other common usage examples
* **test/**: Terratest Go tests for examples

Each example needs: `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`, `terraform.auto.tfvars`, `README.md`

## Test Implementation Pattern

* Use a unique name per test run
* Use `terraform.Plan` for validation
* Use clear, scenario-specific test names
* Organize with shared utilities in `test/shared_test.go`

**Test template:**

```go
func TestModuleExample(t *testing.T) {
    t.Parallel()
    testID := fmt.Sprintf("test-%d", time.Now().Unix())
    terraformOptions := &terraform.Options{
        TerraformDir: "../examples/defaults",
        Vars: map[string]interface{}{"name": testID},
        RetryableTerraformErrors: getRetryableErrors(),
        MaxRetries: 3,
        TimeBetweenRetries: 5 * time.Second,
    }
    defer terraform.Destroy(t, terraformOptions)
    terraform.Init(t, terraformOptions)
    planOutput := terraform.Plan(t, terraformOptions)
    assert.Contains(t, planOutput, "module.main.aws_kms_key.main[0]")
}
```

**Shared helpers:**

```go
func generateTestName(prefix string) string { /* unique Brockhoff Terrafom module names */ }
func getBaseTerraformOptions(dir string) *terraform.Options { /* common options */ }
func getRetryableErrors() map[string]string { /* retry logic for transient errors */ }
```

## Test Types

* **Configuration validation**: Plan succeeds, expected resources created.
* **Feature flag**: Feature is present/absent based on input.
* **Input validation**: Bad inputs fail early.

## Error Handling

* **Retry only transient errors** (timeouts, cloud provider throttling); fail on permanent ones (validation, permissions).

## CI/CD

* Use unique resource names, plan-only tests, and timeouts to control cost and conflicts.
* Run with `make test`.

## AI Agent Guidelines

* **Review**: Is test purpose clear? Will failures be obvious? Are tests isolated and focused on contracts?
* **Generate**: Name tests after scenarios and expected outcomes. Test only what the module promises.
* **Maintain**: Preserve test intent; update assertions as needed; keep tests isolated.
* **Debug**: Check assertion error, inspect plan, validate inputs, run plan manually if needed.

## Anti-Patterns

* **Don’t**: Test all input combinations, implementation details, or write complex, multi-scenario tests in one function.
* **Do**: Test key use cases, contract, and keep logic clear.

## Key Points

1. Test what the module promises, not the cloud provider.
2. One simple, clear purpose per test.
3. Failures must be obvious and actionable.
4. Prefer plan-only tests for speed and cost.
5. All tests must be independent.

---

**Goal:** Simple, essential, and maintainable contract tests for Terraform modules.
