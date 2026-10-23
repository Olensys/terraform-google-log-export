variable "name" {
  description = "Sink name. Lowercase letters, digits and hyphens. Destination names are derived from it (<name>-logs for buckets, underscores for the BigQuery dataset)."
  type        = string
  validation {
    condition     = can(regex("^[a-z0-9-]{1,63}$", var.name))
    error_message = "name must match ^[a-z0-9-]{1,63}$."
  }
}

variable "context" {
  description = "Deployment context used for naming, tagging and environment-dependent defaults."
  type = object({
    organization = string
    environment  = string
    application  = string
    component    = optional(string)
    owner        = string
    cost_center  = string
    extra_tags   = optional(map(string), {})
  })
  validation {
    condition     = contains(["dev", "staging", "prod", "test", "shared"], var.context.environment)
    error_message = "context.environment must be one of dev, staging, prod, test, shared."
  }
}

variable "project_id" {
  description = "ID of the project that owns the sink and the destination."
  type        = string
}

variable "create" {
  description = "Whether to create any resources. Set false to create nothing."
  type        = bool
  default     = true
}

variable "filter" {
  description = "Logging query filter selecting the entries to export. An empty string exports everything."
  type        = string
}

variable "destination" {
  description = "Where to export to. type is logging_bucket, gcs or bigquery. location defaults to global for logging_bucket and US otherwise. retention_days is the log bucket retention, the GCS object expiry age or the BigQuery table expiry."
  type = object({
    type           = string
    location       = optional(string)
    retention_days = optional(number, 30)
  })
  validation {
    condition     = contains(["logging_bucket", "gcs", "bigquery"], var.destination.type)
    error_message = "destination.type must be one of logging_bucket, gcs, bigquery."
  }
  validation {
    condition     = var.destination.retention_days >= 1 && var.destination.retention_days <= 3650
    error_message = "destination.retention_days must be between 1 and 3650."
  }
}

variable "exclusions" {
  description = "Exclusion filters applied to the sink. Entries matching an enabled exclusion are not exported."
  type = list(object({
    name        = string
    filter      = string
    description = optional(string, "")
    disabled    = optional(bool, false)
  }))
  default = []
}

variable "labels" {
  description = "Labels merged onto the destination resources that accept them (Cloud Storage bucket, BigQuery dataset), applied last. Log sinks and logging buckets take no labels."
  type        = map(string)
  default     = {}
}
