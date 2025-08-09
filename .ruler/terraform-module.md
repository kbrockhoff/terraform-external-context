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
