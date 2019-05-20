variable "billing_account" {}
variable "org_id" {}

provider "google" {
 region = "${var.project["region"]}"
}

provider "google-beta" {
 region = "${var.project["region"]}"
}

resource "random_id" "id" {
 byte_length = 4
 prefix      = "${var.project["id"]}"
}

resource "google_project" "project" {
 name            = "${var.project["id"]}"
 project_id      = "${random_id.id.hex}"
 billing_account = "${var.billing_account}"
 org_id          = "${var.org_id}"
}

output "project_id" {
 value = "${google_project.project.project_id}"
}