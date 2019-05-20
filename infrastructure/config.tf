variable "project" {
  type = "map"
  default = {
    "id" = "vibrant-catbird-239806"
    "region" = "europe-west3"
    "zone" = "europe-west3-a"
  }
}

variable "airflow_env" {
  type = "map"
  default = {
    "name" = "premier-league-env"
    "machine_type" = "n1-standard-1"
    "image_version" = "composer-1.6.1-airflow-1.10.1"
    "python_version" = "3"
    "node_count" = "3"
  }
}

variable "datasets" {
  type = "map"
  default = {
    "d1" = "staging"
    "d2" = "view"
    "d3" = "warehouse"
  }
}

variable "tables" {
  type = "map"
  default = {
    "t1" = "matchday"
    "t2" = "scorer"
  }
}

variable "bucket" {
    default = "premier-league"
}