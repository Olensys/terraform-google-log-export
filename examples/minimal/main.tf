terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = { source = "hashicorp/google", version = ">= 6.0, < 8.0" }
  }
}

variable "project_id" {
  description = "Project that owns the sink and the logging bucket."
  type        = string
}

variable "name" {
  description = "Sink name. Deleted logging buckets keep their name for 7 days, so repeated test runs pass a unique value."
  type        = string
  default     = "olensys-test-logs"
}

module "this" {
  source = "../../"

  name       = var.name
  project_id = var.project_id
  context = {
    organization = "olensys"
    environment  = "test"
    application  = "logs"
    owner        = "platform"
    cost_center  = "eng"
  }

  filter = "severity>=WARNING"
  destination = {
    type = "logging_bucket"
  }
}
