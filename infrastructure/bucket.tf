resource "google_storage_bucket" "bucket" {
  name          = "${var.bucket}"
  location      = "EU"
  storage_class = "NEARLINE"
}