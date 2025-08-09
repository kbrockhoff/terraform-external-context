# Terraform Brockhoff Module Makefile
# Optimized for AI agents to reduce LLM calls and token usage

.PHONY: help validate test clean format docs all status pre-commit lint check plan-examples destroy-examples

# Default target
.DEFAULT_GOAL := help

# Colors for output
CYAN := \033[36m
GREEN := \033[32m
YELLOW := \033[33m
RED := \033[31m
RESET := \033[0m

##@ Help
help: ## Display this help message
	@echo "$(CYAN)Terraform AWS S3 Backend Module$(RESET)"
	@echo "$(CYAN)AI-optimized Makefile for efficient development$(RESET)"
	@echo ""
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make $(CYAN)<target>$(RESET)\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  $(CYAN)%-15s$(RESET) %s\n", $$1, $$2 } /^##@/ { printf "\n$(YELLOW)%s$(RESET)\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Validation
pre-commit: ## Run lightweight validation before commit without push (format, validate, lint, docs)
	@echo "$(CYAN)Running pre-commit checks...$(RESET)"
	@$(MAKE) format
	@$(MAKE) check
	@$(MAKE) lint
	@$(MAKE) docs
	@echo "$(GREEN)✓ Pre-commit checks passed$(RESET)"

validate: ## Run complete validation pipeline before commit with push (format, validate, lint, test, docs)
	@echo "$(CYAN)Running complete validation pipeline...$(RESET)"
	@$(MAKE) format
	@$(MAKE) check
	@$(MAKE) lint
	@$(MAKE) test
	@$(MAKE) docs
	@echo "$(GREEN)✓ All validations passed$(RESET)"

check: ## Run Terraform validation on all modules and examples
	@echo "$(CYAN)Validating Terraform configuration...$(RESET)"
	@terraform fmt -check -recursive || (echo "$(RED)✗ Code formatting issues found$(RESET)" && exit 1)
	@echo "$(GREEN)✓ Code formatting OK$(RESET)"
	@for dir in modules/*/; do \
		if [ -f "$$dir/main.tf" ] || [ -f "$$dir/variables.tf" ] || [ -f "$$dir/outputs.tf" ]; then \
			echo "$(CYAN)Validating $$dir...$(RESET)"; \
			(cd "$$dir" && terraform init -backend=false && terraform validate) || exit 1; \
			echo "$(GREEN)✓ $$dir validation passed$(RESET)"; \
		fi; \
	done
	@for dir in examples/*/; do \
		echo "$(CYAN)Validating $$dir...$(RESET)"; \
		(cd "$$dir" && terraform init -backend=false && terraform validate) || exit 1; \
		echo "$(GREEN)✓ $$dir validation passed$(RESET)"; \
	done

format: ## Format all Terraform files
	@echo "$(CYAN)Formatting Terraform files...$(RESET)"
	@terraform fmt -recursive
	@echo "$(GREEN)✓ Formatting complete$(RESET)"

lint: ## Run TFLint on all Terraform files
	@echo "$(CYAN)Running TFLint...$(RESET)"
	@if command -v tflint >/dev/null 2>&1; then \
		tflint --recursive; \
		echo "$(GREEN)✓ TFLint passed$(RESET)"; \
	else \
		echo "$(YELLOW)⚠ TFLint not installed, skipping$(RESET)"; \
	fi

##@ Testing
test:  ## Run all tests
	@echo "$(CYAN)Running tests...$(RESET)"
	@cd test && go mod tidy
	@cd test && go test -v -timeout 30m -parallel 4
	@echo "$(GREEN)✓ All tests passed$(RESET)"

test-defaults:  ## Run only defaults example test
	@echo "$(CYAN)Running defaults test...$(RESET)"
	@cd test && go test -v -timeout 15m -run TestTerraformDefaultsExample
	@echo "$(GREEN)✓ Defaults test passed$(RESET)"

test-complete:  ## Run only complete example test
	@echo "$(CYAN)Running complete test...$(RESET)"
	@cd test && go test -v -timeout 15m -run TestTerraformCompleteExample
	@echo "$(GREEN)✓ Complete test passed$(RESET)"

test-enabled-false:  ## Run only enabled=false test
	@echo "$(CYAN)Running enabled=false test...$(RESET)"
	@cd test && go test -v -timeout 15m -run TestEnabledFalse
	@echo "$(GREEN)✓ Enabled=false test passed$(RESET)"

test-subcontext:  ## Run only subcontext example test
	@echo "$(CYAN)Running subcontext test...$(RESET)"
	@cd test && go test -v -timeout 15m -run TestTerraformSubcontextExample
	@echo "$(GREEN)✓ Subcontext test passed$(RESET)"

##@ Documentation
docs: ## Generate documentation
	@echo "$(CYAN)Generating documentation...$(RESET)"
	@if command -v terraform-docs >/dev/null 2>&1; then \
		terraform-docs .; \
		echo "$(GREEN)✓ Documentation generated$(RESET)"; \
	else \
		echo "$(YELLOW)⚠ terraform-docs not installed, skipping$(RESET)"; \
	fi

##@ Examples
plan-examples:  ## Plan all examples (useful for verification)
	@echo "$(CYAN)Planning all examples...$(RESET)"
	@for dir in examples/*/; do \
		echo "$(CYAN)Planning $$dir...$(RESET)"; \
		(cd "$$dir" && \
			terraform init && \
			terraform plan \
				-var="name_prefix=make-$$(date +%s)" \
				-out=makefile.tfplan) || exit 1; \
		echo "$(GREEN)✓ $$dir plan successful$(RESET)"; \
	done

apply-examples:  ## Apply examples using existing plans (requires plan-examples first)
	@echo "$(CYAN)Applying all example plans...$(RESET)"
	@echo "$(YELLOW)⚠ This will create real AWS resources and incur costs!$(RESET)"
	@echo "$(YELLOW)Press Ctrl+C within 10 seconds to cancel...$(RESET)"
	@sleep 10
	@for dir in examples/*/; do \
		if [ -f "$$dir/makefile.tfplan" ]; then \
			echo "$(CYAN)Applying $$dir...$(RESET)"; \
			(cd "$$dir" && terraform apply makefile.tfplan) || exit 1; \
			echo "$(GREEN)✓ $$dir applied successfully$(RESET)"; \
		else \
			echo "$(RED)✗ No plan file found for $$dir$(RESET)"; \
			echo "$(YELLOW)Run 'make plan-examples' first$(RESET)"; \
			exit 1; \
		fi; \
	done
	@echo "$(GREEN)✓ All examples applied successfully$(RESET)"
	@echo "$(YELLOW)⚠ Don't forget to run 'make destroy-examples' to cleanup resources$(RESET)"

destroy-examples:  ## Destroy any leftover example resources (cleanup)
	@echo "$(CYAN)Cleaning up example resources...$(RESET)"
	@for dir in examples/*/; do \
		echo "$(CYAN)Destroying $$dir...$(RESET)"; \
		(cd "$$dir" && \
			terraform destroy -auto-approve || true); \
		echo "$(GREEN)✓ $$dir cleanup complete$(RESET)"; \
	done

test-examples-full:  ## Full example workflow: plan -> apply -> destroy
	@echo "$(CYAN)Running full example workflow...$(RESET)"
	@echo "$(YELLOW)⚠ This will create and destroy real AWS resources!$(RESET)"
	@$(MAKE) plan-examples
	@$(MAKE) apply-examples
	@sleep 10 # Give resources time to stabilize
	@$(MAKE) destroy-examples
	@echo "$(GREEN)✓ Full example workflow completed$(RESET)"

##@ Status and Information
status: ## Show comprehensive module status
	@echo "$(CYAN)=== Module Status ===$(RESET)"
	@echo "$(YELLOW)Repository:$(RESET)"
	@git remote get-url origin 2>/dev/null || echo "No remote origin"
	@echo "$(YELLOW)Current Branch:$(RESET)"
	@git branch --show-current 2>/dev/null || echo "Not a git repository"
	@echo "$(YELLOW)Git Status:$(RESET)"
	@git status --porcelain 2>/dev/null | head -10 || echo "Clean working directory"
	@echo "$(YELLOW)Terraform Version:$(RESET)"
	@terraform version | head -1
	@echo "$(YELLOW)Go Version:$(RESET)"
	@go version 2>/dev/null || echo "Go not installed"
	@echo "$(YELLOW)Module Files:$(RESET)"
	@find . -name "*.tf" -not -path "./.terraform/*" | wc -l | xargs echo "Terraform files:"
	@echo "$(YELLOW)Test Files:$(RESET)"
	@find test -name "*_test.go" 2>/dev/null | wc -l | xargs echo "Test files:" || echo "Test files: 0"
	@echo "$(YELLOW)Examples:$(RESET)"
	@find examples -name "main.tf" 2>/dev/null | wc -l | xargs echo "Example directories:" || echo "Example directories: 0"

##@ Cleanup
clean: ## Clean up temporary files and caches
	@echo "$(CYAN)Cleaning up...$(RESET)"
	@find . -name ".terraform" -type d -exec rm -rf {} + 2>/dev/null || true
	@find . -name ".terraform.lock.hcl" -delete 2>/dev/null || true
	@find . -name "terraform.tfstate*" -delete 2>/dev/null || true
	@find . -name "*.tfplan" -delete 2>/dev/null || true
	@find . -name "*.log" -delete 2>/dev/null || true
	@echo "$(GREEN)✓ Cleanup complete$(RESET)"

##@ AI Agent Shortcuts
resource-count: ## Show expected resource counts for verification
	@echo "$(CYAN)Expected Resource Counts:$(RESET)"
	@echo "$(YELLOW)Defaults example:$(RESET) 9 resources (KMS key/alias, S3 bucket + configs, DynamoDB table)"
	@echo "$(YELLOW)Complete example:$(RESET) 15 resources (+ SNS topic, 5 CloudWatch alarms)"
	@echo "$(YELLOW)Enabled=false:$(RESET) 0 resources"

verify-tests: ## Verify test structure and names
	@echo "$(CYAN)Test Verification:$(RESET)"
	@cd test && go list -f '{{.Name}}: {{.TestGoFiles}}' . 2>/dev/null || echo "No test package found"
	@echo "$(YELLOW)Expected tests:$(RESET)"
	@echo "  - TestTerraformDefaultsExample"
	@echo "  - TestTerraformCompleteExample" 
	@echo "  - TestEnabledFalse"
	@echo "  - TestTerraformSubcontextExample"

##@ Development
update-branch: ## Update current branch with latest main (merge if exists on origin, rebase if local only)
	@echo "$(CYAN)Updating branch with latest main...$(RESET)"
	@git fetch origin
	@CURRENT_BRANCH=$$(git branch --show-current); \
	if git show-ref --verify --quiet "refs/remotes/origin/$$CURRENT_BRANCH"; then \
		echo "$(CYAN)Branch $$CURRENT_BRANCH exists on origin, merging main...$(RESET)"; \
		git merge origin/main || (echo "$(RED)✗ Merge conflict detected. Please resolve manually.$(RESET)" && exit 1); \
		echo "$(GREEN)✓ Merged main into $$CURRENT_BRANCH$(RESET)"; \
	else \
		echo "$(CYAN)Branch $$CURRENT_BRANCH is local only, rebasing on main...$(RESET)"; \
		git rebase origin/main || (echo "$(RED)✗ Rebase conflict detected. Please resolve manually.$(RESET)" && exit 1); \
		echo "$(GREEN)✓ Rebased $$CURRENT_BRANCH on main$(RESET)"; \
	fi

all: clean validate test docs ## Run complete development workflow
	@echo "$(GREEN)✓ Complete workflow finished$(RESET)"
