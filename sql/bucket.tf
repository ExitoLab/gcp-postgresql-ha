resource "random_id" "bucket_prefix" {
  byte_length = 8
}

resource "google_storage_bucket" "backup_database" {
  name          = "${random_id.bucket_prefix.hex}-pgbackups"
  location      = "US"
  force_destroy = true

  lifecycle_rule {
    condition {
      age = 15
    }
    action {
      type = "Delete"
    }
  }

  versioning {
    enabled = true
  }
}