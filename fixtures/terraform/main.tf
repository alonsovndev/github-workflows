terraform {
  required_version = ">= 1.10"
}

resource "terraform_data" "example" {
  input = "fixture"
}

output "example" {
  value = terraform_data.example.output
}
