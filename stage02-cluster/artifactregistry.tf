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

resource "google_artifact_registry_repository" "benchmarking" {
  project = var.project_id
  location = "us-central1"
  repository_id = "${var.cluster_name}"  # We'll arbitrarily name this after the cluster name.
  format = "DOCKER"

  cleanup_policies {
    id = "keep-tagged-release"
    action = "KEEP"
    condition {
      tag_state = "TAGGED"
      # tag_prefixes = ["release"]
      # package_name_prefixes = ["webapp", "database"]
    }
  }

  cleanup_policies {
    id = "keep-minimum-versions"
    action = "KEEP"
    most_recent_versions {
      # package_name_prefixes = ["webapp"]
      keep_count = 3
    }
  }
}
