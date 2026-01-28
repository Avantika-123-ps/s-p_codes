terraform {
  backend "gcs" {
    bucket = "YOUR_STATE_BUCKET_NAME" # Update this with actual state bucket
    prefix = "terraform/state/nonprod"
  }
}
