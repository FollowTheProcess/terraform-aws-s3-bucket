mock_provider "aws" {
  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{}"
    }
  }
}

run "sets_correct_name" {
  variables {
    name = "my-test-bucket"
  }

  assert {
    condition     = aws_s3_bucket.this.bucket == "my-test-bucket"
    error_message = "incorrect bucket name"
  }
}

run "object_ownership_validates" {
  variables {
    name             = "my-test-bucket"
    object_ownership = "NotOneOfTheOptions"
  }

  command = plan

  expect_failures = [var.object_ownership]
}

run "lifecycle_expiry_negative_integer" {
  variables {
    name                    = "my-test-bucket"
    lifecycle_configuration = { enabled : true, expiration_days : -1 }
  }

  command = plan

  expect_failures = [var.lifecycle_configuration]
}
