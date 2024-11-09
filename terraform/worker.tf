//workers
resource "yandex_compute_instance" "worker" {
  count           = var.worker_count
  name            = "worker-node-${count.index + 1}"
  platform_id     = var.worker_platform
  zone            = var.public_subnet_zones[count.index % length(var.public_subnet_zones)]

  resources {
    cores         = var.worker_cores
    memory        = var.worker_memory
    core_fraction = var.worker_core_fraction
  }

  boot_disk {
    initialize_params {
      image_id = var.image_id
      size     = var.worker_disk_size
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