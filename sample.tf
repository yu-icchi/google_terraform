provider "google" {
  credentials = "${file("${path.module}/credentials/account.json")}"
  project = "seismic-pursuit-123115"
  region = "asia-east1"
}

variable "env" {
  default = "dev"
}

variable "instance_count" {
  default = {
    web = 2
  }
}

variable "availanility_zone" {
  default = {
    "0" = "asia-east1-a"
    "1" = "asia-east1-b"
    "2" = "asia-east1-c"
  }
}

//resource "google_compute_disk" "web-disk" {
//  count = "${lookup(var.instance_count, "web")}"
//  name = "${var.env}-web-disk${count.index + 1}"
//  zone = "asia-east1-a" // "${lookup(var.availanility_zone, count.index % 3)}"
//  type = "pd-standard"
//  size = 200
//}

resource "google_compute_instance" "web" {
  count = "${lookup(var.instance_count, "web")}"

  name = "${var.env}-${format("web-%02d", count.index + 1)}"
  machine_type = "n1-standard-1"
  zone = "asia-east1-a" // "${lookup(var.availanility_zone, count.index % 3)}"
  tags = ["${var.env}"]

  disk {
    image = "centos-6-v20160219"
    type = "pd-ssd"
    auto_delete = true
    size = 10
  }

//  disk {
//    disk = "${var.env}-web-disk${count.index + 1}"
//    device_name = "web-disk"
//  }

  network_interface {
    network = "default"
    access_config {
      // Ephemeral IP
    }
  }

  metadata_startup_script = "echo hi > /test.txt"

}

resource "google_compute_instance_group" "web-group" {
  name = "web-group"
  instances = [
    "${google_compute_instance.web.*.self_link}"
  ]
  named_port {
    name = "http"
    port = "8080"
  }
  named_port {
    name = "https"
    port = "8443"
  }
  zone = "asia-east1-a"
}

//resource "google_compute_ssl_certificate" "web-ssl" {
//  name = "web-ssl"
//  description = "web http load balancing of ssl"
//  private_key = "${file("${path.module}/credentials/server.key")}"
//  certificate = "${file("${path.module}/credentials/server.crt")}"
//}
