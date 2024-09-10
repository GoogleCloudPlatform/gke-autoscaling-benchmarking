# GKE Autoscaling Benchmarking

## Purpose

Runs a series of benchmarks against a workload with HPA enabled within a GKE
cluster.

## Prereqs

*   Ensure you can build docker images locally, without sudo
    (https://docs.docker.com/engine/install/linux-postinstall/#manage-docker-as-a-non-root-user,
    go/installdocker#sudoless-docker).
*   Configure Artifact Registry and install the gcloud CLI credential helper
    (http://cloud.google.com/artifact-registry/docs/docker/authentication,
    go/installdocker#gcr-credential-helper)
*   Ensure you're logged in via gcloud (Hint: `gcloud auth login`)
*   Ensure you can run terraform
    *   Install Terraform version `1.7.5` or higher with
        [these instructions](https://developer.hashicorp.com/terraform/install)

## Instructions

1. Manually create a project with a valid billing account. (These scripts will
   not do this for you).
2. Create the cluster via:
   ```bash
   $ cd stage02-cluster
   $ cp sample-terraform.tfvars terraform.tfvars
   $ vim terraform.tfvars  # edit the values appropriately
   $ terraform init
   $ terraform apply
   ```
3. Create the workload via:
   ```bash
   cd stage03-workload
   terraform init
   terraform apply
   ```
   
   This will create a deployment that will calculate numbers in the fibonacci
   sequence. Feel free to replace this with your own workload.
4. Create the benchmarking tooling (which will run on the same cluster):
   ```bash
   cd stage04-benchmarking
   terraform init
   terraform apply
   ```
5. Start the benchmarking via the locust web UI
   ```bash
   # Get the external IP Addr
   $ gcloud container clusters get-credentials benchmarking --location=us-central1-c
   $ kubectl get svc/locust -n fib -o json | jq '.status.loadBalancer.ingress[0].ip'

   # Now visit the ip addr at port 8089 in your web browser
   ```

   Run the test with **50 users** to start.
