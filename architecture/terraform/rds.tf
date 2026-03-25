resource "aws_db_subnet_group" "main" {
  name       = "interview-eks-db-subnet"
  subnet_ids = [aws_subnet.private_1.id, aws_subnet.private_2.id]

  tags = {
    Name = "interview-eks-db-subnet"
  }
}

resource "aws_db_instance" "postgres" {
  identifier            = "interview-eks-postgres"
  engine               = "postgres"
  engine_version       = "13"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  storage_type         = "gp2"
  skip_final_snapshot  = true

  db_name              = var.db_name
  username             = var.db_username
  password             = var.db_password

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  tags = {
    Name = "interview-eks-postgres"
  }
}
