package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTerraformSubcontextExample(t *testing.T) {
	t.Parallel()
	expectedName := generateTestNamePrefix("sub")

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../examples/subcontext",

		// Variables to pass to our Terraform code using -var options
		Vars: map[string]interface{}{
			"name": expectedName,
		},

		// Environment variables to set when running Terraform
		EnvVars: map[string]string{},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform plan` to validate configuration without creating resources
	terraform.Init(t, terraformOptions)
	planOutput := terraform.Plan(t, terraformOptions)

	// Verify the plan completed without errors and shows no infrastructure changes
	assert.NotEmpty(t, planOutput)
	
	// Context module should not create any infrastructure resources but may show output changes
	// Since this example has outputs defined, we expect "Changes to Outputs" instead of "No changes"
	assert.Contains(t, planOutput, "Changes to Outputs")
	
	// Plan output should show both module instances and their data sources
	assert.Contains(t, planOutput, "module.primary_context.data.external.git_repo[0]")
	assert.Contains(t, planOutput, "module.failover_context.data.external.git_repo[0]")

	// Verify that the plan shows the expected environment configurations
	// The plan output should contain the different environment values
	assert.Contains(t, planOutput, "qapr")
	assert.Contains(t, planOutput, "qafo")
	assert.Contains(t, planOutput, "QA Primary")
	assert.Contains(t, planOutput, "QA Failover")
	
	// Verify that both primary and failover contexts are properly configured
	// The plan should show output values for both contexts
	assert.Contains(t, planOutput, "primary_name_prefix")
	assert.Contains(t, planOutput, "failover_name_prefix")
	assert.Contains(t, planOutput, "primary_context")
	assert.Contains(t, planOutput, "failover_context")
	assert.Contains(t, planOutput, "primary_tags")
	assert.Contains(t, planOutput, "failover_tags")
	assert.Contains(t, planOutput, "primary_data_tags")
	assert.Contains(t, planOutput, "failover_data_tags")
}
