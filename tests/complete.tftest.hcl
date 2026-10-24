# Run only by the nightly integration workflow, against real cloud credentials.
run "apply_minimal" {
  command = apply

  # Deleted logging buckets keep their name for 7 days, so every run needs a fresh one.
  variables {
    name = "olensys-it-${formatdate("YYMMDDhhmmss", timestamp())}"
  }

  module {
    source = "./examples/minimal"
  }
}
