resource "google_bigquery_dataset" "d2" {
  dataset_id = "${var.datasets["d2"]}"
  location = "EU"
  delete_contents_on_destroy = "true"

  access {
    role = "OWNER"
    domain = "bakdata.com"
  }
  access {
    role = "WRITER"
    group_by_email = "${google_service_account.terraform.email}"
  }
}
