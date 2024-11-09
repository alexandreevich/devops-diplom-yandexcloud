output "s3_access_key" {
  description = "Yandex Cloud S3 access key"
  value       = yandex_iam_service_account_static_access_key.sa-static-key.access_key
  sensitive   = true
}

output "s3_secret_key" {
  description = "Yandex Cloud S3 secret key"
  value       = yandex_iam_service_account_static_access_key.sa-static-key.secret_key
  sensitive   = true
}


output "control_plane_ips" {
  description = "Public and internal IP addresses of each control plane node"
  value = [
    for control in yandex_compute_instance.control-plane : {
      name        = control.name
      public_ip   = control.network_interface[0].nat_ip_address
      internal_ip = control.network_interface[0].ip_address
    }
  ]
}

output "worker_nodes_ips" {
  description = "Public and internal IP addresses of each worker node"
  value = [
    for worker in yandex_compute_instance.worker : {
      name        = worker.name
      public_ip   = worker.network_interface[0].nat_ip_address
      internal_ip = worker.network_interface[0].ip_address
    }
  ]
}

output "gitlab_nodes_ips" {
  description = "Public and internal IP addresses of gitlab nodes"
  value = [
    for gitlab-instance in yandex_compute_instance.gitlab-instance : {
      name        = gitlab-instance.name
      public_ip   = gitlab-instance.network_interface[0].nat_ip_address
      internal_ip = gitlab-instance.network_interface[0].ip_address
    }
  ]
}

output "gitlub-runner_ips" {
  description = "Public and internal IP addresses of gitlab nodes"
  value = [
    for gitlub-runner in yandex_compute_instance.gitlab-instance : {
      name        = gitlub-runner.name
      public_ip   = gitlub-runner.network_interface[0].nat_ip_address
      internal_ip = gitlub-runner.network_interface[0].ip_address
    }
  ]
}