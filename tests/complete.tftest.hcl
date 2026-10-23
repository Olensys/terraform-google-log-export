# Run only by the nightly integration workflow, against real cloud credentials.
run "apply_minimal" {
  command = apply

  variables {
    project_id = "example-project"
  }

  module {
    source = "./examples/minimal"
  }
}
