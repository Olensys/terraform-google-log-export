output "id" {
  description = "Resource ID of the log sink (projects/<project>/sinks/<name>). Null when create is false."
  value       = one(module.this[*].log_sink_resource_id)

  precondition {
    condition     = !var.create || var.destination.type != "gcs" || length(var.name) + 5 <= 63
    error_message = "With destination.type = gcs the bucket is named <name>-logs, so name must be at most 58 characters."
  }
}

output "name" {
  description = "Name of the log sink. Null when create is false."
  value       = var.create ? var.name : null
}

output "self_link" {
  description = "Resource path of the log sink, as used by the Cloud Logging API (projects/<project>/sinks/<name>). Null when create is false."
  value       = var.create ? "projects/${var.project_id}/sinks/${var.name}" : null
}

output "writer_identity" {
  description = "Unique service account the sink writes as; it has been granted write access on the destination. Null when create is false."
  value       = one(module.this[*].writer_identity)
}

output "destination_uri" {
  description = "URI of the destination the sink exports to. Null when create is false."
  value       = local.destination_uri
}

output "destination_type" {
  description = "Chosen destination type: logging_bucket, gcs or bigquery. Null when create is false."
  value       = var.create ? var.destination.type : null
}

output "labels" {
  description = "Labels applied to the destination resources that accept them, with context.extra_tags merged in. Null when create is false."
  value       = var.create ? local.labels : null
}
