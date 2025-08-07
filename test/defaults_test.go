package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

const RandomIDLength = 10

func TestTerraformDefaultsExample(t *testing.T) {
	t.Parallel()
	expectedName := generateTestNamePrefix("def")

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "../examples/defaults",

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
	
	// Context module should not create any infrastructure resources
	assert.Contains(t, planOutput, "No changes")
	
	// Plan output should show the computed outputs even without apply
	// Since this is a data-only module, we can validate the plan shows our expected data sources
	assert.Contains(t, planOutput, "data.external.git_repo[0]")

}
