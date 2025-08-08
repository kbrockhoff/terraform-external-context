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
	
	// Context module should not create any infrastructure resources
	assert.Contains(t, planOutput, "No changes")
	
	// Plan output should show both module instances and their data sources
	assert.Contains(t, planOutput, "module.primary_context.data.external.git_repo[0]")
	assert.Contains(t, planOutput, "module.failover_context.data.external.git_repo[0]")

	// Apply the configuration to test outputs
	terraform.Apply(t, terraformOptions)

	// Test that both contexts produce different name prefixes
	primaryPrefix := terraform.Output(t, terraformOptions, "primary_name_prefix")
	failoverPrefix := terraform.Output(t, terraformOptions, "failover_name_prefix")

	// Verify name prefixes follow expected pattern
	assert.Contains(t, primaryPrefix, "ck-qaprim-"+expectedName)
	assert.Contains(t, failoverPrefix, "ck-qafo-"+expectedName)
	
	// Verify the prefixes are different (different environments)
	assert.NotEqual(t, primaryPrefix, failoverPrefix)

	// Test that context inheritance works - both should have same base configuration
	primaryContext := terraform.OutputMap(t, terraformOptions, "primary_context")
	failoverContext := terraform.OutputMap(t, terraformOptions, "failover_context")

	// Both contexts should have the same namespace and name
	assert.Equal(t, primaryContext["namespace"], failoverContext["namespace"])
	assert.Equal(t, primaryContext["name"], failoverContext["name"])
	
	// But different environments
	assert.Equal(t, "qaprim", primaryContext["environment"])
	assert.Equal(t, "qafo", failoverContext["environment"])
	
	// And different environment names
	assert.Equal(t, "QA Primary", primaryContext["environment_name"])
	assert.Equal(t, "QA Failover", failoverContext["environment_name"])

	// Test tag inheritance - both should have base tags but different environment-specific values
	primaryTags := terraform.OutputMap(t, terraformOptions, "primary_tags")
	failoverTags := terraform.OutputMap(t, terraformOptions, "failover_tags")

	// Both should have common tags
	assert.Equal(t, primaryTags["ck-namespace"], failoverTags["ck-namespace"])
	assert.Equal(t, primaryTags["ck-name"], failoverTags["ck-name"])
	assert.Equal(t, primaryTags["ck-product"], failoverTags["ck-product"])
	
	// But different environment tags
	assert.Equal(t, "qaprim", primaryTags["ck-environment"])
	assert.Equal(t, "qafo", failoverTags["ck-environment"])
	assert.Equal(t, "QA Primary", primaryTags["ck-environment-name"])
	assert.Equal(t, "QA Failover", failoverTags["ck-environment-name"])

	// Test data tags inheritance and differences
	primaryDataTags := terraform.OutputMap(t, terraformOptions, "primary_data_tags")
	failoverDataTags := terraform.OutputMap(t, terraformOptions, "failover_data_tags")

	// Both should have common data tags
	assert.Equal(t, primaryDataTags["DataClassification"], failoverDataTags["DataClassification"])
	assert.Equal(t, primaryDataTags["RetentionPeriod"], failoverDataTags["RetentionPeriod"])
	
	// Failover should have additional tag showing primary relationship
	assert.Contains(t, failoverDataTags["FailoverPrimary"], "ck-qaprim-"+expectedName)
	assert.NotContains(t, primaryDataTags, "FailoverPrimary")
}