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
