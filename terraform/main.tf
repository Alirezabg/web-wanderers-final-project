##################
# CONFIGURATION
##################

locals {
  project_id = "planar-elevator-374616"
}
terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "4.43.0"
    }
  }
}


provider "google" {
  project     = local.project_id
  region      = "us-central1"
  zone        = "us-central1-c"
  credentials = file("terra.json")
}
resource "google_project_service" "project" {
  service = "compute.googleapis.com"
  lifecycle {
    prevent_destroy = true
  }
}
resource "google_compute_firewall" "default" {
  name    = "web-firewall"
  network = "default"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "3000", "4000"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web"]
}
resource "google_compute_network" "default" {
  name = "my-network"
}
resource "google_compute_subnetwork" "default" {
  name          = "my-subnet"
  ip_cidr_range = "10.0.0.0/16"
  region        = "us-central1"
  network       = google_compute_network.default.id
}
resource "google_compute_instance" "virtual_instance" {
  name         = "frontend"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network = "default"
    access_config {}
  }
    metadata_startup_script = file("frontend.sh")
  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    # email  = google_service_account.default.email
    scopes = ["cloud-platform"]
    //full access or default
    // list of permissions https://cloud.google.com/sdk/gcloud/reference/alpha/compute/instances/set-scopes#--scopes
  }
  tags = ["http-server", "https-server", "web"]

}
resource "google_compute_instance" "virtual_instance2" {
  name         = "api-server"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network = "default"
    access_config {}
  }
    metadata_startup_script = file("api-server.sh")
  service_account {
  #   # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
  #   email  = google_service_account.default.email
    scopes = ["cloud-platform"] 
    //full access or default
    // list of permissions https://cloud.google.com/sdk/gcloud/reference/alpha/compute/instances/set-scopes#--scopes
  }
  tags = ["http-server", "https-server", "web"]

}

resource "google_sql_database_instance" "main" {
  name                = "main-instance"
  database_version    = "POSTGRES_14"
  region              = "us-central1"
  deletion_protection = false
  settings {
    # Second-generation instance tiers are based on the machine
    # type. See argument reference below.
    tier = "db-f1-micro"

  }
}
