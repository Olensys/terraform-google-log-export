locals {
  extra_labels = { for k, v in var.context.extra_tags :
  substr(replace(lower(k), "/[^a-z0-9_-]/", "-"), 0, 63) => substr(replace(lower(v), "/[^a-z0-9_-]/", "-"), 0, 63) }
  labels = merge(local.extra_labels, var.labels)

  type     = var.destination.type
  location = coalesce(var.destination.location, local.type == "logging_bucket" ? "global" : "US")

  bucket_name  = "${var.name}-logs"
  dataset_name = replace(var.name, "-", "_")

  destination_uri = var.create ? coalesce(
    try(module.logbucket[0].destination_uri, null),
    try(module.storage[0].destination_uri, null),
    try(module.bigquery[0].destination_uri, null),
  ) : null
}

module "this" {
  source  = "terraform-google-modules/log-export/google"
  version = "11.1.0"

  count = var.create ? 1 : 0

  log_sink_name        = var.name
  parent_resource_id   = var.project_id
  parent_resource_type = "project"
  destination_uri      = local.destination_uri
  filter               = var.filter

  # A dedicated writer identity per sink, so the grant never widens to other sinks.
  unique_writer_identity = true
  include_children       = false

  # BigQuery sinks write date-partitioned tables instead of sharded ones.
  bigquery_options = local.type == "bigquery" ? { use_partitioned_tables = true } : null

  exclusions = [for e in var.exclusions : {
    name        = e.name
    description = e.description
    filter      = e.filter
    disabled    = e.disabled
  }]
}

module "logbucket" {
  source  = "terraform-google-modules/log-export/google//modules/logbucket"
  version = "11.1.0"

  count = var.create && local.type == "logging_bucket" ? 1 : 0

  project_id               = var.project_id
  name                     = local.bucket_name
  location                 = local.location
  retention_days           = var.destination.retention_days
  log_sink_writer_identity = module.this[0].writer_identity

  # The bucket lives in the sink's own project, where Cloud Logging writes without a grant
  # and returns no writer identity, so the upstream IAM member would get an empty member.
  grant_write_permission_on_bkt = false
}

module "storage" {
  source  = "terraform-google-modules/log-export/google//modules/storage"
  version = "11.1.0"

  count = var.create && local.type == "gcs" ? 1 : 0

  project_id               = var.project_id
  storage_bucket_name      = local.bucket_name
  location                 = local.location
  storage_bucket_labels    = local.labels
  log_sink_writer_identity = module.this[0].writer_identity

  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  lifecycle_rules = [{
    action    = { type = "Delete" }
    condition = { age = tostring(var.destination.retention_days) }
  }]
}

module "bigquery" {
  source  = "terraform-google-modules/log-export/google//modules/bigquery"
  version = "11.1.0"

  count = var.create && local.type == "bigquery" ? 1 : 0

  project_id               = var.project_id
  dataset_name             = local.dataset_name
  location                 = local.location
  labels                   = local.labels
  expiration_days          = var.destination.retention_days
  log_sink_writer_identity = module.this[0].writer_identity
}
