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

variable "project_id" {
  description = "Project ID to use. APIs will be enabled and clusters, etc. created in this project."
  type        = string
  nullable    = false
}

variable "cluster_name" {
  description = "Name of the cluster to be created"
  type        = string
  nullable    = false
}

variable "cluster_location" {
  description = "Location of the cluster."
  type        = string
  nullable    = false
  default     = "us-central1-c"
}

variable "e2_nodepool" {
  description = "Settings for the e2 nodepool."
  type = object({
    enabled = bool
    # TODO: enable other parameters, such as machine size, min/max node count, etc.
  })
  nullable = false
  default = {
    enabled = true
  }
}
