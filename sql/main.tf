# Create a primary database instance
resource "google_sql_database_instance" "primary_instance" {
  name             = "primary-db"
  database_version = "POSTGRES_12"
  region           = var.region

  settings {
    tier              = "db-custom-2-7168" #db-n1-standard-2
    activation_policy = "ALWAYS"

    ip_configuration {
      ipv4_enabled    = true
      private_network = google_compute_network.database_vpc_network.self_link
      require_ssl     = false
    }
  }

  /* depends_on = [
    google_compute_network.database_vpc_network,
    google_project_service.enable_google_apis
  ] */

  # Wait for the vpc connection to complete
  depends_on = [google_service_networking_connection.private_vpc_connection]
}

/*
resource "google_sql_user" "user" {
  name     = "myuser"
  instance = google_sql_database_instance.primary_instance.name
  password = "mypassword"
  depends_on = [
    "google_sql_database_instance.primary_instance"
  ]

  // Set the user's host
  host = "%"
}


# Create the sql postgres database
resource "google_sql_database" "pgbench" {
  name     = "pgbench"
  instance = google_sql_database_instance.primary_instance.name

  // Set the username and password for the database
  project = var.project_id

  charset   = "UTF8"
  collation = "en_US.UTF8"

  provisioner "local-exec" {
    command = "psql postgresql://${google_sql_user.user.name}:${google_sql_user.user.password}@${google_sql_database_instance.primary_instance.public_ip_address}/postgres -c \"CREATE SCHEMA pgbench; \""
  }
} */

/*
resource "google_sql_user_instance" "myuser" {
  name     = "myuser"
  instance = google_sql_database_instance.primary_instance.name
  password = "mypassword"

  // Set custom labels for the resource
  user_labels = {
    my_label = "my_value"
  }
}

resource "google_sql_database_instance_tier2" "pgbench_init" {
  depends_on = [
    google_sql_database.pgbench,
  ]

  provider      = google-beta
  name          = "pgbench-init"
  database      = google_sql_database.mydatabase.name
  instance      = google_sql_database_instance.primary_instance.name
  source        = "pgbench.sql"
  database_type = "POSTGRES"
  db_version    = "POSTGRES_12"
  user          = google_sql_user.myuser.name
  password      = google_sql_user.myuser.password
  region        = google_sql_database_instance.primary_instance.region

  // Specify the init label to only run this script once
  user_labels = {
    "init" = "pgbench"
  }
} */
