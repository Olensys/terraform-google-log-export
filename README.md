# terraform-google-log-export

Project log sink with a filter and exclusions, exporting to a Cloud Logging bucket, Cloud Storage or BigQuery with the writer identity granted

## Opinions

- Project-level sink only, with `unique_writer_identity = true` (the grant never widens to other sinks) and `include_children = false`.
- The destination is created by the module and the sink's writer identity is granted on it (`roles/logging.bucketWriter`, `roles/storage.objectCreator` or `roles/bigquery.dataEditor`, as the upstream submodules do).
- Destination names derive from `name`: logging and Cloud Storage buckets are `<name>-logs` (so `name` is limited to 58 characters with `gcs`), the BigQuery dataset is `name` with hyphens turned into underscores.
- `destination.location` defaults to `global` for `logging_bucket` and `US` for `gcs` and `bigquery`.
- `destination.retention_days` (default 30) is the log bucket retention, a Cloud Storage `Delete` lifecycle rule on object age, or the BigQuery default table expiry. No locked retention policy is set.
- Cloud Storage buckets use uniform bucket-level access and enforced public access prevention.
- Log sinks and logging buckets take no labels; `labels` (merged with `context.extra_tags`) are applied to the Cloud Storage bucket and BigQuery dataset only.
- The caller owns project API enablement beyond what the upstream submodules enable for their destination service.

## Usage

```hcl
module "this" {
  source = "git::https://github.com/Olensys/terraform-google-log-export.git?ref=v1.0.0"

  name       = "example"
  project_id = "my-project"
  context = {
    organization = "olensys"
    environment  = "dev"
    application  = "example"
    owner        = "platform"
    cost_center  = "eng"
  }

  filter = "severity>=WARNING"
  destination = {
    type = "logging_bucket"
  }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
| ---- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_google"></a> [google](#requirement\_google) | >= 6.0, < 8.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
| ---- | ------ | ------- |
| <a name="module_bigquery"></a> [bigquery](#module\_bigquery) | terraform-google-modules/log-export/google//modules/bigquery | 11.1.0 |
| <a name="module_logbucket"></a> [logbucket](#module\_logbucket) | terraform-google-modules/log-export/google//modules/logbucket | 11.1.0 |
| <a name="module_storage"></a> [storage](#module\_storage) | terraform-google-modules/log-export/google//modules/storage | 11.1.0 |
| <a name="module_this"></a> [this](#module\_this) | terraform-google-modules/log-export/google | 11.1.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
| ---- | ----------- | ---- | ------- | :------: |
| <a name="input_context"></a> [context](#input\_context) | Deployment context used for naming, tagging and environment-dependent defaults. | <pre>object({<br/>    organization = string<br/>    environment  = string<br/>    application  = string<br/>    component    = optional(string)<br/>    owner        = string<br/>    cost_center  = string<br/>    extra_tags   = optional(map(string), {})<br/>  })</pre> | n/a | yes |
| <a name="input_destination"></a> [destination](#input\_destination) | Where to export to. type is logging\_bucket, gcs or bigquery. location defaults to global for logging\_bucket and US otherwise. retention\_days is the log bucket retention, the GCS object expiry age or the BigQuery table expiry. | <pre>object({<br/>    type           = string<br/>    location       = optional(string)<br/>    retention_days = optional(number, 30)<br/>  })</pre> | n/a | yes |
| <a name="input_filter"></a> [filter](#input\_filter) | Logging query filter selecting the entries to export. An empty string exports everything. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Sink name. Lowercase letters, digits and hyphens. Destination names are derived from it (<name>-logs for buckets, underscores for the BigQuery dataset). | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | ID of the project that owns the sink and the destination. | `string` | n/a | yes |
| <a name="input_create"></a> [create](#input\_create) | Whether to create any resources. Set false to create nothing. | `bool` | `true` | no |
| <a name="input_exclusions"></a> [exclusions](#input\_exclusions) | Exclusion filters applied to the sink. Entries matching an enabled exclusion are not exported. | <pre>list(object({<br/>    name        = string<br/>    filter      = string<br/>    description = optional(string, "")<br/>    disabled    = optional(bool, false)<br/>  }))</pre> | `[]` | no |
| <a name="input_labels"></a> [labels](#input\_labels) | Labels merged onto the destination resources that accept them (Cloud Storage bucket, BigQuery dataset), applied last. Log sinks and logging buckets take no labels. | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
| ---- | ----------- |
| <a name="output_destination_type"></a> [destination\_type](#output\_destination\_type) | Chosen destination type: logging\_bucket, gcs or bigquery. Null when create is false. |
| <a name="output_destination_uri"></a> [destination\_uri](#output\_destination\_uri) | URI of the destination the sink exports to. Null when create is false. |
| <a name="output_id"></a> [id](#output\_id) | Resource ID of the log sink (projects/<project>/sinks/<name>). Null when create is false. |
| <a name="output_labels"></a> [labels](#output\_labels) | Labels applied to the destination resources that accept them, with context.extra\_tags merged in. Null when create is false. |
| <a name="output_name"></a> [name](#output\_name) | Name of the log sink. Null when create is false. |
| <a name="output_self_link"></a> [self\_link](#output\_self\_link) | Resource path of the log sink, as used by the Cloud Logging API (projects/<project>/sinks/<name>). Null when create is false. |
| <a name="output_writer_identity"></a> [writer\_identity](#output\_writer\_identity) | Unique service account the sink writes as; it has been granted write access on the destination. Null when create is false. |
<!-- END_TF_DOCS -->
