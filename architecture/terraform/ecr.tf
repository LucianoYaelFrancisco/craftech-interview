resource "aws_ecr_repository" "backend" {
  name                 = "interview-backend"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  tags = {
    Name = "interview-backend-repo"
  }
}

resource "aws_ecr_repository" "frontend" {
  name                 = "interview-frontend"
  image_tag_mutability = "MUTABLE"
  force_delete         = true

  tags = {
    Name = "interview-frontend-repo"
  }
}
