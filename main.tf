// GCP Global Load Balancer
resource "google_logging_project_exclusion" "global_lb" {
  count = var.exclude_glb_percent > 0 ? 1 : 0

  name        = "glb-access-logs"
  description = "Exclude GLB access logs. Managed by Terraform."

  filter = <<EOT
resource.type="http_load_balancer"
${var.exclude_glb_https_requests_only == true ? "httpRequest.requestUrl:\"http://\"" : ""}
${var.exclude_glb_severity_expression}
( ( trace:* sample(trace, ${var.exclude_glb_percent == 100 ? 1 : "0.${var.exclude_glb_percent}00000000000001"}) ) OR
  ( NOT trace:* operation.id:* sample(operation.id, ${var.exclude_glb_percent == 100 ? 1 : "0.${var.exclude_glb_percent}00000000000001"}) ) OR
  ( NOT trace:* NOT operation.id:* sample(insertId, ${var.exclude_glb_percent == 100 ? 1 : "0.${var.exclude_glb_percent}00000000000001"}) ) )
EOT
}

// k8s containers
resource "google_logging_project_exclusion" "k8s_containers" {
  count = var.exclude_k8s_containers_percent > 0 ? 1 : 0
  depends_on = [google_logging_project_exclusion.global_lb] // API can handle one resource at the time only

  name = "k8s-containers"
  description = "Exclude k8s containers logs, except for from the whitelisted namespaces. Managed by Terraform."

  filter = <<EOT
resource.type="k8s_container"
${length(var.exclude_k8s_containers_namespace_whistelist) > 0 ? "resource.labels.namespace_name!=(${join(" OR ", var.exclude_k8s_containers_namespace_whistelist)})" : ""}
${var.exclude_k8s_containers_severity_expression}
( ( trace:* sample(trace, ${var.exclude_k8s_containers_percent == 100 ? 1 : "0.${var.exclude_k8s_containers_percent}00000000000001"}) ) OR
  ( NOT trace:* operation.id:* sample(operation.id, ${var.exclude_k8s_containers_percent == 100 ? 1 : "0.${var.exclude_k8s_containers_percent}00000000000001"}) ) OR
  ( NOT trace:* NOT operation.id:* sample(insertId, ${var.exclude_k8s_containers_percent == 100 ? 1 : "0.${var.exclude_k8s_containers_percent}00000000000001"}) ) )
EOT
}

// k8s system nginx
resource "google_logging_project_exclusion" "k8s_system_nginx" {
  count      = var.exclude_k8s_system_nginx_percent > 0 ? 1 : 0
  depends_on = [google_logging_project_exclusion.k8s_containers] // API can handle one resource at the time only

  name        = "k8s-system-nginx"
  description = "Exclude k8s system nginx logs. Managed by Terraform."

  filter = <<EOT
resource.type="k8s_container"
resource.labels.namespace_name="system"
resource.labels.container_name="nginx"
${var.exclude_k8s_system_nginx_severity_expression}
( ( trace:* sample(trace, ${var.exclude_k8s_system_nginx_percent == 100 ? 1 : "0.${var.exclude_k8s_system_nginx_percent}00000000000001"}) ) OR
  ( NOT trace:* operation.id:* sample(operation.id, ${var.exclude_k8s_system_nginx_percent == 100 ? 1 : "0.${var.exclude_k8s_system_nginx_percent}00000000000001"}) ) OR
  ( NOT trace:* NOT operation.id:* sample(insertId, ${var.exclude_k8s_system_nginx_percent == 100 ? 1 : "0.${var.exclude_k8s_system_nginx_percent}00000000000001"}) ) )
EOT
}
