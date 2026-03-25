data "aws_region" "current" {}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "interview-eks-vpc"
  }
}

# Subnets públicas para ALB
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name                            = "interview-eks-public-1"
    "kubernetes.io/role/elb"        = "1"
    "kubernetes.io/cluster/interview-eks-cluster" = "owned"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name                            = "interview-eks-public-2"
    "kubernetes.io/role/elb"        = "1"
    "kubernetes.io/cluster/interview-eks-cluster" = "owned"
  }
}

# Subnet privada
resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = data.aws_availability_zones.available.names[0]

  tags = {
    Name                            = "interview-eks-private-1"
    "kubernetes.io/role/internal-elb" = "1" 
    "kubernetes.io/cluster/interview-eks-cluster" = "owned"
  }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = data.aws_availability_zones.available.names[1]

  tags = {
    Name                            = "interview-eks-private-2"
    "kubernetes.io/role/internal-elb" = "1" 
    "kubernetes.io/cluster/interview-eks-cluster" = "owned"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "interview-eks-igw"
  }
}

# VPC ENDPOINTS

# Security Group para VPC Endpoints
resource "aws_security_group" "vpce" {
  name        = "interview-vpce-sg"
  description = "Firewall para VPC Endpoints"
  vpc_id      = aws_vpc.main.id

  # Permite HTTPS desde cualquier IP en la VPC
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "interview-vpce-sg"
  }
}

# VPC Endpoint para ECR API (autenticación)
resource "aws_vpc_endpoint" "ecr_api" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.api"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [aws_subnet.private_1.id, aws_subnet.private_2.id]
  security_group_ids  = [aws_security_group.vpce.id]

  tags = {
    Name = "interview-ecr-api-endpoint"
  }
}

# VPC Endpoint para ECR DKR (descargar imágenes)
resource "aws_vpc_endpoint" "ecr_dkr" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [aws_subnet.private_1.id, aws_subnet.private_2.id]
  security_group_ids  = [aws_security_group.vpce.id]

  tags = {
    Name = "interview-ecr-dkr-endpoint"
  }
}

# VPC Endpoint para CloudWatch Logs (enviar logs)
resource "aws_vpc_endpoint" "logs" {
  vpc_id              = aws_vpc.main.id
  service_name        = "com.amazonaws.${data.aws_region.current.name}.logs"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true
  subnet_ids          = [aws_subnet.private_1.id, aws_subnet.private_2.id]
  security_group_ids  = [aws_security_group.vpce.id]

  tags = {
    Name = "interview-logs-endpoint"
  }
}

# VPC Endpoint para S3 (almacenamiento)
resource "aws_vpc_endpoint" "s3" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"

  tags = {
    Name = "interview-s3-endpoint"
  }
}

# Route tables
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block      = "0.0.0.0/0"
    gateway_id      = aws_internet_gateway.main.id
  }

  tags = {
    Name = "interview-eks-rt-public"
  }
}

# Elastic IP para NAT Gateway AZ-1
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "interview-eks-eip-nat-1"
  }

  depends_on = [aws_internet_gateway.main]
}

# NAT Gateway en la subnet pública 1 (AZ-1)
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_1.id

  tags = {
    Name = "interview-eks-nat-1"
  }

  depends_on = [aws_internet_gateway.main]
}

# Elastic IP para NAT Gateway AZ-2
resource "aws_eip" "nat_2" {
  domain = "vpc"

  tags = {
    Name = "interview-eks-eip-nat-2"
  }

  depends_on = [aws_internet_gateway.main]
}

# NAT Gateway en la subnet pública 2 (AZ-2)
resource "aws_nat_gateway" "main_2" {
  allocation_id = aws_eip.nat_2.id
  subnet_id     = aws_subnet.public_2.id

  tags = {
    Name = "interview-eks-nat-2"
  }

  depends_on = [aws_internet_gateway.main]
}

# Route table para subnet privada AZ-1
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "interview-eks-rt-private-1"
  }
}

# Route table para subnet privada AZ-2
resource "aws_route_table" "private_2" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main_2.id
  }

  tags = {
    Name = "interview-eks-rt-private-2"
  }
}

# Asociaciones
resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private_2.id
}

data "aws_availability_zones" "available" {
  state = "available"
}
