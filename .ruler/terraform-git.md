# AI Agent Git Operations for Terraform Repositories

## Core Principles

**Simplicity First**: Each operation should have a single, clear purpose. Avoid complecting git operations with unrelated concerns.

**Composable Workflow**: Each stage builds independently on the previous, allowing for easy debugging and iteration.

## Branch Management

### Creating Branches
- **Format**: `feature/descriptive-name` or `fix/issue-description`
- **Source**: Always branch from `main`
- **Naming**: Use kebab-case, be specific about the change

```bash
git checkout main
git pull origin main
git checkout -b feature/add-to-module
```

### Keeping Branches Current
- **Method**: Rebase only (preserve linear history)
- **Frequency**: Daily, or before any major work session
- **Conflict Resolution**: Address conflicts immediately

```bash
git fetch origin
git rebase origin/main
```

## Pre-Commit Standards

### Complete Validation Pipeline (Recommended)
```bash
# Single command runs complete validation: format, validate, lint, test, docs
make validate
```

### Individual Validation Steps (If Needed)
Use these for specific validation needs:

1. **Code Formatting**
   ```bash
   make format
   ```

2. **Module & Example Validation**
   ```bash
   make check
   ```

3. **Linting**
   ```bash
   make lint
   ```

4. **Documentation Generation**
   ```bash
   make docs
   ```

5. **Test Execution**
   ```bash
   make test
   ```

## Commit Standards

### Message Format
Follow [Conventional Commits 1.0.0](https://www.conventionalcommits.org/):

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Examples
```
feat(vpc): add multi-az subnet configuration
fix(security-group): resolve circular dependency issue
docs(readme): update module usage examples
test(vpc): add integration test for NAT gateway
```

### Commit Scope
- **Atomic Changes**: One logical change per commit
- **Complete Units**: Each commit should leave the repository in a working state
- **Clear Intent**: Commit message should explain *why*, not just *what*

## Pull Request Workflow

### Pre-PR Validation
Ensure all pre-commit checks pass:
```bash
# Complete validation pipeline
make validate
```

### Alternative: Pre-commit Only (No Tests)
For quick validation without running AWS-dependent tests:
```bash
make pre-commit
```

### PR Requirements
1. **Title**: Must follow Conventional Commits format
2. **Description**: Complete all GitHub template sections
3. **Scope**: Single concern per PR (avoid complecting multiple features)
4. **Size**: Prefer smaller, focused PRs over large, complex ones

### PR Template Sections (All Required)
- [ ] **Summary**: What does this PR accomplish?
- [ ] **Changes**: Specific modifications made
- [ ] **Testing**: How was this validated?
- [ ] **Breaking Changes**: Any backwards compatibility concerns?
- [ ] **Documentation**: What docs were updated?

## Quality Gates

### Automated Checks (Must Pass)
Run `make validate` to ensure all of the following pass:
- Terraform formatting (`make format`)
- Module & example validation (`make check`)
- TFLint compliance (`make lint`)
- All tests passing (`make test`)
- Documentation generation (`make docs`)

### Manual Review Focus
- **Simplicity**: Is the solution as simple as possible?
- **Composition**: Are components properly decoupled?
- **Clarity**: Is the intent obvious from the code?
- **Testability**: Can changes be easily validated?

## Troubleshooting

### Common Issues
1. **Rebase Conflicts**: Resolve immediately, don't accumulate
2. **Test Failures**: Fix root cause, don't mask symptoms
3. **Lint Errors**: Address policy violations, don't suppress

### Recovery Patterns
```bash
# Reset to clean state if needed
git reset --hard origin/main

# Clean workspace
git clean -fd

# Clean Terraform temporary files
make clean
```

## Notes for AI Agents

### Recommended Workflow Commands
- **Development validation**: `make validate` (complete pipeline)
- **Quick checks**: `make pre-commit` (no tests, no AWS needed)
- **AWS session check**: `make check-aws` (verify AWS access before tests)
- **Module information**: `make status` (comprehensive project info)
- **Resource verification**: `make resource-count` (expected resource counts)
- **Cleanup**: `make clean` (remove temporary files)

### Best Practices
- **Fail Fast**: Use `make validate` to stop pipeline on first error
- **Context Preservation**: Use `make status` for project information gathering
- **Rollback Strategy**: Always know how to undo changes with git and `make clean`
- **AWS Validation**: Makefile automatically validates AWS session for tests
- **Efficiency**: Single commands replace multiple manual operations
