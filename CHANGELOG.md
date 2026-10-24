# Changelog

## [1.1.1](https://github.com/Olensys/terraform-google-log-export/compare/v1.1.0...v1.1.1) (2026-10-24)


### Bug Fixes

* run integration on change and weekly instead of nightly ([fd2165e](https://github.com/Olensys/terraform-google-log-export/commit/fd2165ea305f8c2a30c2e9a5cb51ca878bc938ec))

## 1.1.0

### Fixes

- normalise `context.extra_tags` keys and values to valid GCP label syntax (lowercase, invalid characters to `-`, 63 characters); `labels` still win

### Tests

- `test_tags_contract` covers a mixed-case tag key and a value with a space

### Docs

- README usage shows the naming module

### Behaviour changes

- `context.extra_tags` entries now appear as normalised labels (for example `Team = "Core Team"` becomes `team = "core-team"`). Callers that relied on unnormalised keys must read the normalised ones; values that previously failed GCP label validation now succeed.

## 1.0.1

### Fixes

- partitioned BigQuery sink tables, stricter name validation, smoke-labelled destination tests

## 1.0.0

- Project log sink with a filter and exclusions, exporting to a Cloud Logging bucket, Cloud Storage or BigQuery.
- Writes through a unique writer identity that is granted on the destination created by the module.
- Wraps terraform-google-modules/log-export/google 11.1.0 and its logbucket, storage and bigquery submodules.
