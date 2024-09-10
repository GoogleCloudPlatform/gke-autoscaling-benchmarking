# Instructions: Copy this file to terraform.tfvars and adjust the values as
# appropriate.

# Fill in your project id here.
project_id = "PROJECT_ID"

# Choose a name for your cluster. (Leaving it as "benchmarking" is fine.)
cluster_name = "benchmarking"

e2_nodepool = {
  enabled = true
}
