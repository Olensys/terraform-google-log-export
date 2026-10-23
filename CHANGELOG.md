# Changelog

## 1.0.1

### Fixes

- partitioned BigQuery sink tables, stricter name validation, smoke-labelled destination tests

## 1.0.0

- Project log sink with a filter and exclusions, exporting to a Cloud Logging bucket, Cloud Storage or BigQuery.
- Writes through a unique writer identity that is granted on the destination created by the module.
- Wraps terraform-google-modules/log-export/google 11.1.0 and its logbucket, storage and bigquery submodules.
