resource "local_file" "ansible_inventory" {
  content = <<-EOF
    [all]
    %{ for i, control in yandex_compute_instance.control-plane ~}
    ${control.network_interface[0].nat_ip_address} ansible_user=${var.ansible_user} ansible_ssh_private_key_file=${var.ansible_ssh}
    %{ endfor ~}
    %{ for worker in yandex_compute_instance.worker ~}
    ${worker.network_interface[0].nat_ip_address} ansible_user=${var.ansible_user} ansible_ssh_private_key_file=${var.ansible_ssh}
    %{ endfor ~}

    [control_plane]
    %{ for i, control in yandex_compute_instance.control-plane ~}
    ${control.network_interface[0].nat_ip_address} ansible_user=${var.ansible_user} ansible_ssh_private_key_file=${var.ansible_ssh}
    %{ endfor ~}

    [workers]
    %{ for worker in yandex_compute_instance.worker ~}
    ${worker.network_interface[0].nat_ip_address} ansible_user=${var.ansible_user} ansible_ssh_private_key_file=${var.ansible_ssh}
    %{ endfor ~}
  EOF

  filename = "/Users/sashamac/testdrive/inventory.ini"
}
