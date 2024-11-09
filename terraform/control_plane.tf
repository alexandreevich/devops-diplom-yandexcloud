//master-node
resource "yandex_compute_instance" "control-plane" {
  count           = var.control_count
  name            = "control-plane-node-${count.index + 1}"
  platform_id     = var.platform
  zone            = var.public_subnet_zones[count.index % length(var.public_subnet_zones)]
  
  resources {
    cores         = var.control_plane_core
    memory        = var.control_plane_memory
    core_fraction = var.control_plane_core_fraction
  }

  boot_disk {
    initialize_params {
    
      image_id = var.image_id
      size     = var.control_plane_disk_size
    }
  }

  scheduling_policy {
    preemptible = var.scheduling_policy
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public_subnet[count.index % length(var.public_subnet_zones)].id
    nat       = var.nat
  }

  metadata = {
    user-data = "${file("./meta.txt")}"
  }
}
