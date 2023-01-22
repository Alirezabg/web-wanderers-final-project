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
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}
resource "google_compute_address" "static" {
  name = "ipv4-address"
}
resource "google_compute_firewall" "default" {
  name    = "web-firewall"
  network = "my-network"

  allow {
    protocol = "icmp"
  }

  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "3000", "4000", "5432"]
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
      image = module.gce-worker-container.source_image
    }
  }
  network_interface {
    network = "default"
    access_config {

    }
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
resource "google_compute_disk" "pd" {
  project = local.project_id
  name    = "test-data-disk"
  type    = "pd-ssd"
  size    = 10
}
resource "google_compute_instance" "vm" {
  machine_type = "e2-micro"
  zone         = "us-central1-a"
  name         = "test"


  boot_disk {
    initialize_params {
      image = module.gce-worker-container.source_image
    }
  }



  network_interface {
    subnetwork = "default"
    access_config {}
  }


  labels = {
    container-vm = module.gce-worker-container.vm_container_label
  }

  tags = ["container-vm-example", "container-vm-test-disk-instance"]

  service_account {
    email = "terraform@planar-elevator-374616.iam.gserviceaccount.com"
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }
}
module "gce-worker-container" {
  source = "terraform-google-modules/container-vm/google"
  container = {
    image = "gcr.io/google-samples/hello-app:1.0"
    env = [
      {
        name  = "TEST_VAR"
        value = "Hello World!"
      }
    ],

    # Declare volumes to be mounted.
    # This is similar to how docker volumes are declared.
    volumeMounts = [
      {
        mountPath = "/cache"
        name      = "tempfs-0"
        readOnly  = false
      },
      {
        mountPath = "/persistent-data"
        name      = "data-disk-0"
        readOnly  = false
      },
    ]

    privileged_mode = true
    activate_tty    = true
    # custom_command = [
    #   "./start-worker.sh"
    # ]
    env_variables = {
      Q_CLUSTER_WORKERS = "2"
      DB_HOST           = "your-database-host"
      DB_PORT           = "5432"
      DB_ENGINE         = "django.db.backends.postgresql"
      DB_NAME           = "db_production"
      DB_SCHEMA         = "jafar_prd"
      DB_USER           = "role_jafar_prd"
      DB_PASS           = "this-is-my-honest-password"
      DB_USE_SSL        = "True"
    }

    # This has the permission to download images from Container Registry
  }
  volumes = [
    {
      name = "tempfs-0"

      emptyDir = {
        medium = "Memory"
      }
    },
    {
      name = "data-disk-0"

      gcePersistentDisk = {
        pdName = "data-disk-0"
        fsType = "ext4"
      }
    },
  ]

  restart_policy = "Always"
}

resource "google_compute_instance" "virtual_instance2" {
  name         = "api-server"
  machine_type = "e2-micro"
  zone         = "us-central1-a"

  boot_disk {
    initialize_params {
      image = "cos-stable-80-12739-91-0"
      size  = "10"
      type  = "pd-standard"
    }
  }
  metadata = {
    gce-container-declaration = "spec:\n  containers:\n  - name: instance-1\n    image: us-central1-docker.pkg.dev/planar-elevator-374616/quickstart-docker-repo/quickstart-image:tag1\n    args:\n    - ''\n    stdin: false\n    tty: false\n  restartPolicy: Always\n# This container declaration format is not public API and may change without notice. Please\n# use gcloud command-line tool or Google Cloud Console to run Containers on Google Compute Engine.",
    key                       = "gce-container-declaration"
    google-logging-enabled    = "true"
  }
  network_interface {
    network = "default"
    access_config {

    }
  }
  # metadata_startup_script = file("api-server.sh")

  service_account {
    #   # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    #   email  = google_service_account.default.email
    scopes = ["cloud-platform"]
    //full access or default
    // list of permissions https://cloud.google.com/sdk/gcloud/reference/alpha/compute/instances/set-scopes#--scopes
  }
  tags = ["http-server", "https-server", "web"]

}

# resource "google_sql_database_instance" "postgres" {
#   name                = "main-instance"
#   database_version    = "POSTGRES_14"
#   region              = "us-central1"
#   deletion_protection = false

#   settings {
#     # Second-generation instance tiers are based on the machine
#     # type. See argument reference below.
#     tier = "db-f1-micro"

#   }

# }




