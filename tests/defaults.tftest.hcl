mock_provider "google" {
  mock_resource "google_logging_project_sink" {
    defaults = {
      id              = "projects/example-project/sinks/example"
      writer_identity = "serviceAccount:o1234-5678@gcp-sa-logging.iam.gserviceaccount.com"
    }
  }
  mock_resource "google_logging_project_bucket_config" {
    defaults = {
      id = "projects/example-project/locations/global/buckets/example-logs"
    }
  }
}

variables {
  context = {
    organization = "olensys"
    environment  = "test"
    application  = "example"
    owner        = "platform"
    cost_center  = "eng"
  }
  name       = "example"
  project_id = "example-project"
  filter     = "severity>=WARNING"
  destination = {
    type = "logging_bucket"
  }
}

run "test_logging_bucket_default" {
  command = apply

  assert {
    condition     = output.destination_type == "logging_bucket"
    error_message = "The default destination must be the logging bucket."
  }

  assert {
    condition     = output.name == "example"
    error_message = "The sink name must be var.name."
  }

  assert {
    condition     = startswith(output.destination_uri, "logging.googleapis.com/")
    error_message = "The sink must route to the logging bucket URI."
  }
}

run "test_destination_type_validation" {
  command = plan

  variables {
    destination = { type = "pubsub" }
  }

  expect_failures = [var.destination]
}

run "test_writer_identity_granted" {
  command = apply

  # SMOKE: asserts only that the sink exposes the (mocked) writer identity that is passed to the destination module; the IAM binding itself lives inside the upstream submodule and is proven by tests/complete.tftest.hcl.
  assert {
    condition     = output.writer_identity == "serviceAccount:o1234-5678@gcp-sa-logging.iam.gserviceaccount.com"
    error_message = "The sink must expose its writer identity."
  }
}

run "test_create_false_plans_nothing" {
  command = plan

  variables {
    create = false
  }

  assert {
    condition     = output.id == null && output.name == null && output.self_link == null && output.writer_identity == null && output.destination_uri == null && output.destination_type == null && output.labels == null
    error_message = "Every output must be null when create is false."
  }
}

run "test_tags_contract" {
  command = plan

  variables {
    labels = { owner = "x" }
    context = {
      organization = "olensys"
      environment  = "test"
      application  = "example"
      owner        = "platform"
      cost_center  = "eng"
      extra_tags   = { owner = "y", team = "z" }
    }
  }

  assert {
    condition     = output.labels.owner == "x"
    error_message = "var.labels must win over context.extra_tags."
  }

  assert {
    condition     = output.labels.team == "z"
    error_message = "context.extra_tags must be merged into labels."
  }
}

run "test_gcs_destination" {
  command = apply

  variables {
    destination = { type = "gcs" }
  }

  assert {
    condition     = output.destination_type == "gcs"
    error_message = "destination_type must reflect the gcs choice."
  }

  assert {
    condition     = startswith(output.destination_uri, "storage.googleapis.com/")
    error_message = "The sink must route to the storage bucket URI."
  }
}

run "test_bigquery_destination" {
  command = apply

  variables {
    destination = { type = "bigquery" }
  }

  assert {
    condition     = output.destination_type == "bigquery"
    error_message = "destination_type must reflect the bigquery choice."
  }

  assert {
    condition     = startswith(output.destination_uri, "bigquery.googleapis.com/")
    error_message = "The sink must route to the dataset URI."
  }
}

run "test_exclusions_passed" {
  command = plan

  variables {
    exclusions = [
      { name = "drop-health", filter = "httpRequest.requestUrl:\"/healthz\"" },
      { name = "drop-debug", description = "debug noise", filter = "severity=DEBUG", disabled = true },
    ]
  }

  # SMOKE: asserts the exclusions input is accepted and the plan succeeds; the rendered exclusion blocks live in the upstream sink resource and are proven by tests/complete.tftest.hcl.
  assert {
    condition     = output.name == "example"
    error_message = "Planning with exclusions must succeed."
  }
}

run "test_name_length_validation" {
  command = plan

  variables {
    name = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
  }

  expect_failures = [var.name]
}

run "test_gcs_name_length_precondition" {
  command = plan

  variables {
    name        = "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    destination = { type = "gcs" }
  }

  expect_failures = [output.id]
}
