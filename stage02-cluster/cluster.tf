# Copyright 2024 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

resource "google_service_account" "cluster_sa" {
  account_id = "${var.cluster_name}-sa"
  display_name = "${var.cluster_name} Cluster Service Account"
  project = var.project_id
}

resource "google_project_iam_binding" "cluster_sa_project_binding_ar" {
  project = google_artifact_registry_repository.benchmarking.project
  role = "roles/artifactregistry.reader"
  members = [
    "serviceAccount:${google_service_account.cluster_sa.email}",
  ]
}

resource "google_project_iam_binding" "cluster_sa_project_binding_default" {
  project = var.project_id
  # Needs to be able to write to the Autoscaling, Monitoring and Logging APIs.
  role = "roles/container.defaultNodeServiceAccount"
  members = [
    "serviceAccount:${google_service_account.cluster_sa.email}"
  ]
}

resource "google_container_cluster" "cluster" {
  depends_on = [google_project_service.container]
  name = var.cluster_name
  description = "Benchmarking cluster"
  project = var.project_id
  location = var.cluster_location
  deletion_protection = false
  release_channel {
    channel = "RAPID"
  }
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  remove_default_node_pool = true
  initial_node_count = 1

  vertical_pod_autoscaling {
    enabled = true
  }
  #enable_autopilot = false
  cluster_autoscaling {
    enabled = true
    autoscaling_profile = "OPTIMIZE_UTILIZATION"
    resource_limits {
      resource_type = "cpu"
      minimum = 4
      maximum = 100
    }
    resource_limits {
      resource_type = "memory"
      minimum = 16
      maximum = 400
    }
  }
}

resource "google_container_node_pool" "e2-nodepool" {
  count    = var.e2_nodepool.enabled ? 1 : 0
  name     = "e2-nodepool"
  project  = google_container_cluster.cluster.project
  location = google_container_cluster.cluster.location
  cluster  = google_container_cluster.cluster.id

  autoscaling {
    min_node_count = 1
    max_node_count = 20
  }

  management {
    auto_upgrade = true
    auto_repair = true
  }

  node_config {
    preemptible = false
    machine_type = "e2-standard-4"
    service_account = google_service_account.cluster_sa.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

# Uncomment the following if you want to use pre-warmed nodes. Otherwise
# the test will rely on NAP to spin up nodes for you.
# Be sure to set node_count to an appropriate value.

# resource "google_container_node_pool" "nodepool-1" {
#   name = "${var.cluster_name}-nodepool-1"
#   node_count = 25
#   location = var.cluster_location
#   cluster = google_container_cluster.cluster.name
#   project = var.project_id
#   node_config {
#     preemptible  = true
#     machine_type = "e2-highcpu-4"
#     service_account = google_service_account.cluster_sa.email
#     oauth_scopes = [
#       "https://www.googleapis.com/auth/cloud-platform"
#     ]
#   }
# }
