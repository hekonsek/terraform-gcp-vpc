package test

import (
    "fmt"
    "os"
    "strings"
    "testing"

    "github.com/gruntwork-io/terratest/modules/random"
    "github.com/gruntwork-io/terratest/modules/terraform"
    "github.com/stretchr/testify/require"
)

// getEnvAny returns the first non-empty value among the given env vars.
func getEnvAny(names ...string) string {
    for _, n := range names {
        if v := strings.TrimSpace(os.Getenv(n)); v != "" {
            return v
        }
    }
    return ""
}

func getenvDefault(name, def string) string {
    if v := strings.TrimSpace(os.Getenv(name)); v != "" {
        return v
    }
    return def
}

// Run with: `cd test && go test -v -timeout 45m`
// Required: export GOOGLE_CLOUD_PROJECT=<your-project-id> (or set TF_VAR_project_id)
func TestVPCModule_ApplyAndVerify(t *testing.T) {
    if os.Getenv("TERRATEST_SKIP_DEPLOY") != "" {
        t.Skip("TERRATEST_SKIP_DEPLOY set; skipping deploy")
    }

    projectID := getEnvAny("TF_VAR_project_id", "GOOGLE_CLOUD_PROJECT", "GOOGLE_PROJECT")
    if projectID == "" {
        t.Skip("Set GOOGLE_CLOUD_PROJECT or TF_VAR_project_id to run this test")
    }

    // Configurable via env, with sane defaults
    networkCIDR := getenvDefault("TERRATEST_NETWORK_CIDR", "10.64.0.0/20")
    podsCIDR := getenvDefault("TERRATEST_PODS_CIDR", "10.80.0.0/14")
    servicesCIDR := getenvDefault("TERRATEST_SERVICES_CIDR", "10.96.0.0/20")
    podsRangeName := getenvDefault("TERRATEST_PODS_RANGE_NAME", "pods")
    servicesRangeName := getenvDefault("TERRATEST_SERVICES_RANGE_NAME", "services")

    uniqueID := strings.ToLower(random.UniqueId())
    networkName := fmt.Sprintf("test-vpc-%s", uniqueID)

    tfOpts := &terraform.Options{
        TerraformDir: "./",
        // We run Terraform in the test folder which references the module from repo root
        // by using module "vpc" { source = "./.." } inside test/test.tf.
        // To keep the working directory consistent, set TerraformDir to the test folder.
        // Note: the test binary is launched from the test folder when using the README command.
        Vars: map[string]interface{}{
            "project_id":            projectID,
            "network_name":          networkName,
            "network_cidr":          networkCIDR,
            "pods_cidr":             podsCIDR,
            "services_cidr":         servicesCIDR,
            "pods_ip_range_name":    podsRangeName,
            "services_ip_range_name": servicesRangeName,
        },
        EnvVars: map[string]string{
            // Help Terraform and the Google provider pick up project ID consistently
            "TF_IN_AUTOMATION":     "true",
            "GOOGLE_PROJECT":       projectID,
            "GOOGLE_CLOUD_PROJECT": projectID,
        },
        NoColor: true,
    }

    // Execute
    defer terraform.Destroy(t, tfOpts)
    terraform.InitAndApply(t, tfOpts)

    // Validate root outputs defined in test/test.tf
    vpcName := terraform.Output(t, tfOpts, "vpc_name")
    require.Equal(t, networkName, vpcName, "VPC name should match the requested network_name")

    podsRange := terraform.Output(t, tfOpts, "pods_range_name")
    require.Equal(t, podsRangeName, podsRange)

    servicesRange := terraform.Output(t, tfOpts, "services_range_name")
    require.Equal(t, servicesRangeName, servicesRange)

    subnetName := terraform.Output(t, tfOpts, "subnet")
    require.Contains(t, subnetName, networkName, "Subnet name should include network name by default")
}

