provider "aws" {
  region = "eu-central-1"
}

resource "aws_ecr_repository" "app" {
  name                 = "platsbokning"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

output ecr_repository_url {
  value = aws_ecr_repository.app.repository_url
}