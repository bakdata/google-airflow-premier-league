resource "google_service_account" "terraform" {
  account_id = "terraform"
}

resource "google_service_account_key" "mykey" {
  service_account_id = "${google_service_account.terraform.name}"
}

resource "kubernetes_secret" "google-application-credentials" {
  metadata = {
    name = "google-application-credentials"
  }
  data {
    credentials.json = "${base64decode(google_service_account_key.mykey.private_key)}"
  }
}