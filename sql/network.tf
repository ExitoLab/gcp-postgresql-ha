resource "random_id" "name" {
  byte_length = 2
}

locals {
  # If name_override is specified, use that - otherwise use the name_prefix with a random string
  private_network_name = "private-network-${random_id.name.hex}"
  private_ip_name      = "private-ip-${random_id.name.hex}"
}

# Create a VPC network for the primary and standby database instances
resource "google_compute_network" "database_vpc_network" {
  name                    = "database-vpc-network"
  auto_create_subnetworks = false
}

# Reserve global internal address range for the peering
resource "google_compute_global_address" "private_ip_address" {
  name          = local.private_ip_name
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.database_vpc_network.self_link
}

# Establish VPC network peering connection using the reserved address range
resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.database_vpc_network.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

# Create a subnet for the primary and standby database instances in the VPC network
resource "google_compute_subnetwork" "database_subnet" {
  name          = "database-subnet"
  ip_cidr_range = "10.0.1.0/24"
  network       = google_compute_network.database_vpc_network.self_link
  region        = var.region
}

/* # Create a firewall rule to allow traffic between the primary and standby database instances
resource "google_compute_firewall" "database_firewall" {
  name    = "database-firewall"
  network = google_compute_network.database_vpc_network.self_link
  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }
  source_ranges = [
    google_compute_subnetwork.database_subnet.ip_cidr_range
  ]
  target_tags = ["database"]
} */

