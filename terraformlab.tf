terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 4.0"
    }
  }
}


provider "google" {
    project = "devops-343007"
}
###################  managment  ################################
resource "google_compute_network" "mngt-vpc-ws" {
    name = "mngt-vpc-ws"
    auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "mngt-subnet-ws" {
name = "mngt-subnet-ws"
ip_cidr_range = "172.16.0.0/24"
region = "europe-west3"
network = google_compute_network.mngt-vpc-ws.id
}

resource "google_compute_instance" "mngt-vm-ws" {
  name         = "mngt-vm-ws"
  machine_type = "e2-medium"
  zone         = "europe-west3-a"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
}
  network_interface {
    subnetwork = google_compute_subnetwork.mngt-subnet-ws.id
  }
}


###################  development   ################################
//dev-vpc
resource "google_compute_network" "dev-vpc-ws" {
    name = "dev-vpc-ws"
    auto_create_subnetworks = false
}
//dev-subnet-1
resource "google_compute_subnetwork" "ws-dev-subnet-1" {
name = "ws-dev-subnet-1"
ip_cidr_range = "10.0.1.0/24"
region = "europe-west2"
network = google_compute_network.dev-vpc-ws.id
}
//dev-subnet-2
resource "google_compute_subnetwork" "ws-dev-subnet-2" {
name = "ws-dev-subnet-2"
ip_cidr_range = "10.0.2.0/24"
region = "us-west2"
network = google_compute_network.dev-vpc-ws.id
}
//dev-webserver-1
resource "google_compute_instance" "dev-webserver1-ws" {
  name         = "dev-webserver1-ws"
  machine_type = "e2-medium"
  zone         = "europe-west2-b"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
}
  network_interface {
    subnetwork = google_compute_subnetwork.ws-dev-subnet-1.id
  }
}
//dev-webserver-2
resource "google_compute_instance" "dev-webserver2-ws" {
  name         = "dev-webserver2"
  machine_type = "e2-medium"
  zone         = "europe-west2-c"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
}
  network_interface {
    subnetwork = google_compute_subnetwork.ws-dev-subnet-2.id
  }
}
//instance group 

resource "google_compute_instance_group" "instance-group-dev-ws" {
  name        = "dev-webserversgroup-ws"
  description = "Terraform test instance group"

  instances = [
    google_compute_instance.dev-webserver1-ws.id,
    google_compute_instance.dev-webserver2-ws.id,
  ]
  zone = "europe-west2"
}

//dev-sqlserver-1

resource "google_compute_instance" "dev-sqlserver1-ws" {
  name         = "sql-webserver1-ws"
  machine_type = "e2-medium"
  zone         = "europe-west2-b"
  boot_disk {
    initialize_params {
      image = "windows-sql-cloud/sql-ent-2012-win-2012-r2"
    }
}
  network_interface {
    subnetwork = google_compute_subnetwork.ws-dev-subnet-1.id
  }
}
//dev-sqlserver-2

resource "google_compute_instance" "dev-sqlserver2-ws" {
  name         = "prod-sqlserver2-ws"
  machine_type = "e2-medium"
  zone         = "europe-west2-c"
  boot_disk {
    initialize_params {
      image = "windows-sql-cloud/sql-ent-2012-win-2012-r2"
    }
}
  network_interface {
    subnetwork = google_compute_subnetwork.ws-prod-subnet-2.id
  }
}
//peering1 -managment <-> development
resource "google_compute_network_peering" "peering1" {
  name         = "peering1"
  network      = google_compute_network.dev-vpc-ws.self_link
  peer_network = google_compute_network.mngt-vpc-ws.self_link
}
//peering 2 managment <-> production
resource "google_compute_network_peering" "peering2" {
  name         = "peering2"
  network      = google_compute_network.mngt-vpc-ws.self_link
  peer_network = google_compute_network.prod-vpc-ws.self_link
}

###################  production vpc  ################################
//production vpc
resource "google_compute_network" "prod-vpc-ws" {
    name = "prod-vpc-ws"
    auto_create_subnetworks = false
}
//prod-subnet-1
resource "google_compute_subnetwork" "ws-prod-subnet-1" {
name = "ws-prod-subnet-1"
ip_cidr_range = "192.168.1.0/24"
region = "europe-west2"
network = google_compute_network.prod-vpc-ws.id
}
//prod-subnet-2
resource "google_compute_subnetwork" "ws-prod-subnet-2" {
name = "ws-prod-subnet-2"
ip_cidr_range = "192.168.2.0/24"
region = "us-west2"
network = google_compute_network.prod-vpc-ws.id
}
//prod-webserver-1
resource "google_compute_instance" "prod-webserver1-ws" {
  name         = "prod-webserver1-ws"
  machine_type = "e2-medium"
  zone         = "europe-west2-b"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
}
  network_interface {
    subnetwork = google_compute_subnetwork.ws-prod-subnet-1.id
  }
}
//production webserver 2
resource "google_compute_instance" "prod-webserver2-ws" {
  name         = "prod-webserver2"
  machine_type = "e2-medium"
  zone         = "europe-west2-c"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-9"
    }
}
  network_interface {
    subnetwork = google_compute_subnetwork.ws-prod-subnet-2.id
  }
}
//instance group 2

resource "google_compute_instance_group" "instance-group-prod-ws" {
  name        = "dev-webserversgroup-ws"
  description = "Terraform test instance group"

  instances = [
    google_compute_instance.prod-webserver1-ws.id,
    google_compute_instance.prod-webserver2-ws.id,
  ]
  zone = "europe-west2"
}

//prod-sqlserver-1
resource "google_compute_instance" "prod-sqlserver1-ws" {
  name         = "prod-sqlserver1-ws"
  machine_type = "e2-medium"
  zone         = "europe-west2-b"
  boot_disk {
    initialize_params {
      image = "windows-sql-cloud/sql-ent-2012-win-2012-r2"
    }
}
  network_interface {
    subnetwork = google_compute_subnetwork.ws-dev-subnet-1.id
  }
}
//prod-sqlserver-2

resource "google_compute_instance" "prod-sqlserver2-ws" {
  name         = "prod-sqlserver2-ws"
  machine_type = "e2-medium"
  zone         = "europe-west2-c"
  boot_disk {
    initialize_params {
      image = "windows-sql-cloud/sql-ent-2012-win-2012-r2"
    }
}
  network_interface {
    subnetwork = google_compute_subnetwork.ws-dev-subnet-2.id
  }
}
//peering
resource "google_compute_network_peering" "peering3" {
  name         = "peering3"
  network      = google_compute_network.prod-vpc-ws.self_link
  peer_network = google_compute_network.mngt-vpc-ws.self_link
}
resource "google_compute_network_peering" "peering4" {
  name         = "peering4"
  network      = google_compute_network.mngt-vpc-ws.self_link
  peer_network = google_compute_network.prod-vpc-ws.self_link
}


################ firewall rules ###########################

//managnent - development ---md
resource "google_compute_firewall" "md-firewall" {
  name        = "md-firewall"
  network     = google_compute_network.dev-vpc-ws.id
  allow {
    protocol  = "tcp"
    ports     = ["80"]
  }
  source_tags = ["172.16.0.0/24"]
}

//clients - production ---cp
resource "google_compute_firewall" "cp-firewall" {
  name        = "cp-firewall"
  network     = google_compute_network.prod-vpc-ws.id
  allow {
    protocol  = "tcp"
    ports     = ["80"]
  }
  source_tags = ["0.0.0.0/0"]
}

//prod lb
resource "google_compute_forwarding_rule" "prod-lb-ws" {
  name       = "prod-lb-ws"
  target     = google_compute_target_pool.prod-lb-ws.id
  port_range = "80"
}
resource "google_compute_target_pool" "prod-lb-ws" {
  name = "website-target-pool"
}
//dev lb
resource "google_compute_forwarding_rule" "dev-lb-ws" {
  name       = "dev-lb-ws"
  target     = google_compute_target_pool.dev-lb-ws.id
  port_range = "80"
}
resource "google_compute_target_pool" "dev-lb-ws" {
  name = "website-target-pool"
}