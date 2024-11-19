//gitlub
resource "yandex_compute_instance" "gitlab-instance" {
  count    = 1
  name     = "gitlab"


  resources {
    core_fraction = 20
    cores         = 4
    memory        = 8
  }

  boot_disk {
    initialize_params {
      image_id = "fd83t0mf3eavtntooatl"
      size = 25
    }
  }


  network_interface {
    subnet_id = yandex_vpc_subnet.public_subnet[count.index % length(var.public_subnet_zones)].id
    nat       = true
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    user-data = "${file("./meta.txt")}"
  }

}
resource "yandex_vpc_network" "network-1" {
}




