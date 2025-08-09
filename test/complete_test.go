package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTerraformCompleteExample(t *testing.T) {
	t.Parallel()
	expectedName := generateTestNamePrefix("comp")

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../examples/complete",

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"name":             expectedName,
			"environment_type": "None",
		},

		// Environment variables to set when running Terraform
		EnvVars: map[string]string{},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform plan` to validate configuration without creating resources
	terraform.Init(t, terraformOptions)
	planOutput := terraform.Plan(t, terraformOptions)

	// Verify the plan completed without errors
	assert.NotEmpty(t, planOutput)
	
	// Context module should not create any infrastructure resources, but may execute external data source
	assert.Contains(t, planOutput, "data.external.git_repo[0]")
	
	// Plan should show no infrastructure changes
	assert.Contains(t, planOutput, "No changes")

}

func TestEnabledFalse(t *testing.T) {
	t.Parallel()
	expectedName := generateTestNamePrefix("comp")

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../examples/complete",

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"enabled":          false,
			"name":             expectedName,
			"environment_type": "None",
		},

		// Environment variables to set when running Terraform
		EnvVars: map[string]string{},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform plan` to validate disabled behavior
	terraform.Init(t, terraformOptions)
	planOutput := terraform.Plan(t, terraformOptions)

	// Verify plan shows no changes when module is disabled
	assert.NotEmpty(t, planOutput)
	assert.Contains(t, planOutput, "No changes")

}

func TestSourceRepoTagsDisabled(t *testing.T) {
	t.Parallel()
	expectedName := generateTestNamePrefix("nosrc")

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../examples/complete",

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"name":                     expectedName,
			"environment_type":         "None", 
			"source_repo_tags_enabled": false,
		},

		// Environment variables to set when running Terraform
		EnvVars: map[string]string{},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform plan` to validate no external data source
	terraform.Init(t, terraformOptions)
	planOutput := terraform.Plan(t, terraformOptions)

	// Verify the plan completed without errors
	assert.NotEmpty(t, planOutput)
	
	// Should not execute external data source when source repo tags disabled
	assert.NotContains(t, planOutput, "data.external.git_repo[0]")
	
	// Plan should show no infrastructure changes
	assert.Contains(t, planOutput, "No changes")

}
