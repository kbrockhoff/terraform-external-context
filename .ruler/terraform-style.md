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
