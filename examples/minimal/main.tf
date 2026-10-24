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

module "this" {
  source = "../../"

  name       = "olensys-test-logs"
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
