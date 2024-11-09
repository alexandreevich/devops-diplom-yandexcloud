terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">=0.13"
  
  # backend "s3" {
  #   endpoint   = "storage.yandexcloud.net"
  #   bucket     = "diplom-project-alexandreevich"
  #   region     = "ru-central1-a"
  #   key        = "terraform.tfstate"
  #   access_key = ""
  #   secret_key = ""

  #   skip_region_validation      = true
  #   skip_credentials_validation = true
  # }

}





provider "yandex" {
  token     = var.token
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.default_zone
  }