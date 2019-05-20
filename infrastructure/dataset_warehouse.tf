resource "google_bigquery_dataset" "d3" {
  dataset_id = "${var.datasets["d3"]}"
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

resource "google_bigquery_table" "t1" {
  dataset_id = "${google_bigquery_dataset.d3.dataset_id}"
  table_id = "${var.tables["t1"]}"

  schema = "${file("${var.tables["t1"]}_schema.json")}"
}

resource "google_bigquery_table" t2 {
  dataset_id = "${google_bigquery_dataset.d3.dataset_id}"
  table_id = "${var.tables["t2"]}"

  schema = "${file("${var.tables["t2"]}_schema.json")}"
}