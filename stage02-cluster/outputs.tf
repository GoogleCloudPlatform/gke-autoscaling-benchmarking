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

output "cluster" {
  value = google_container_cluster.cluster
  sensitive = true
}

output "project_id" {
  value = var.project_id
}

output "artifact_registry_uri" {
  value = "${google_artifact_registry_repository.benchmarking.location}-docker.pkg.dev/${google_artifact_registry_repository.benchmarking.project}/${google_artifact_registry_repository.benchmarking.repository_id}"
}
