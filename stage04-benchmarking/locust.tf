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

resource "terraform_data" "build_locust" {
  triggers_replace = [
    sha1(join("", [for f in fileset("locust", "**"): filesha1("locust/${f}")])),
    local.artifact_registry_uri,
  ]

  provisioner "local-exec" {
    command = "docker build -t locust:latest -t ${local.artifact_registry_uri}/locust:latest ${path.module}/locust && docker push ${local.artifact_registry_uri}/locust:latest"
  }
  input = "${local.artifact_registry_uri}/locust:latest"
}

resource "kubernetes_deployment_v1" "locust" {
  metadata {
    name = "locust"
    namespace = local.fib_svc.metadata[0].namespace
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "locust"
      }
    }
    template {
      metadata {
        labels = {
          app = "locust"
        }
      }
      spec {
        container {
          name = "locust"
          image = terraform_data.build_locust.output
          image_pull_policy = "Always"
          command = ["locust", "-f", "/locust/simple.py", "--host", "http://fib.${local.fib_svc.metadata[0].namespace}.svc.cluster.local:5000", "--users", "50", "--spawn-rate", "1", "--run-time", "10m"]
          resources {
            requests = {
              cpu = "50m"
              memory = "128Mi"
            }
            limits = {
              cpu = "2000m"
              memory = "128Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "locust" {
  metadata {
    namespace = local.fib_svc.metadata[0].namespace
    name = "locust"
  }
  spec {
    type = "LoadBalancer"
    external_traffic_policy = "Cluster"
    selector = {
      app = "locust"
    }
    port {
      name = "tcp-port"
      protocol = "TCP"
      port = 8089
      target_port = 8089
    }
  }
}
