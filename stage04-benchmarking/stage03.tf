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

data "terraform_remote_state" "stage03" {
  backend = "local"
  config = {
    path = "../stage03-workload/terraform.tfstate"
  }
}

locals {
  fib_svc = data.terraform_remote_state.stage03.outputs.fib_svc
  artifact_registry_uri = data.terraform_remote_state.stage03.outputs.artifact_registry_uri
  cluster = data.terraform_remote_state.stage03.outputs.cluster
}
