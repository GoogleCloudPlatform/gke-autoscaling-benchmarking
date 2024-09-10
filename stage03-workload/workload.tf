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

resource "terraform_data" "build_fib" {
  triggers_replace = [
    sha1(join("", [for f in fileset("workload", "**") : filesha1("workload/${f}")])),
    local.artifact_registry_uri,
  ]

  provisioner "local-exec" {
    command = "docker build -t fib:latest -t ${local.artifact_registry_uri}/fib:latest ${path.module}/workload && docker push ${local.artifact_registry_uri}/fib:latest"
  }
  input = "${local.artifact_registry_uri}/fib:latest"
}

resource "kubernetes_namespace_v1" "fib" {
  metadata {
    name = "fib"
  }
}

resource "kubernetes_deployment_v1" "fib" {
  metadata {
    name      = "fib"
    namespace = kubernetes_namespace_v1.fib.metadata[0].name
  }
  spec {
    replicas = 1
    selector {
      match_labels = {
        app = "fib"
      }
    }
    template {
      metadata {
        labels = {
          app = "fib"
        }
      }
      spec {
        container {
          name              = "fib"
          image             = terraform_data.build_fib.output
          image_pull_policy = "Always"
          resources {
            requests = {
              cpu    = "1000m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "2000m"
              memory = "128Mi"
            }
          }
          port {
            container_port = 5000
            name           = "web"
            protocol       = "TCP"
          }
        }
        node_selector = var.node_selector
      }
    }
  }
}

resource "kubernetes_horizontal_pod_autoscaler_v2" "fib" {
  metadata {
    name      = "fib"
    namespace = kubernetes_namespace_v1.fib.metadata[0].name
  }
  spec {
    min_replicas = 5
    max_replicas = 250
    scale_target_ref {
      api_version = "apps/v1"
      kind        = "Deployment"
      name        = kubernetes_deployment_v1.fib.metadata[0].name
    }
    metric {
      type = "Resource"
      resource {
        name = "cpu"
        target {
          type                = "Utilization"
          average_utilization = "70"
        }
      }
    }
    behavior {
      scale_down {
        stabilization_window_seconds = 60
        policy {
          period_seconds = 15
          type           = "Percent"
          value          = 100
        }
        select_policy = "Min"
      }
      scale_up {
        stabilization_window_seconds = 0
        policy {
          period_seconds = 15
          type           = "Percent"
          value          = 100
        }
        policy {
          period_seconds = 15
          type           = "Pods"
          value          = 1000
        }
        select_policy = "Max"
      }
    }
  }
}

resource "kubernetes_service_v1" "fib" {
  metadata {
    namespace = kubernetes_namespace_v1.fib.metadata[0].name
    name      = "fib"
  }
  spec {
    type                    = "LoadBalancer"
    external_traffic_policy = "Cluster"
    selector = {
      app = "fib"
    }
    port {
      name        = "tcp-port"
      protocol    = "TCP"
      port        = 5000
      target_port = 5000
    }
  }
}
