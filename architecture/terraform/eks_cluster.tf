resource "aws_eks_cluster" "main" {
  name            = var.cluster_name
  version         = "1.29"
  role_arn        = aws_iam_role.eks_cluster_role.arn
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  vpc_config {
    subnet_ids              = [
      aws_subnet.public_1.id,
      aws_subnet.public_2.id,
      aws_subnet.private_1.id,
      aws_subnet.private_2.id
    ]
    security_group_ids      = [aws_security_group.eks_cluster.id]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  tags = {
    Name = "interview-eks-cluster"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy
  ]
}

# OIDC Provider para IRSA (IAM Roles for Service Accounts)
data "tls_certificate" "cluster" {
  url = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.main.identity[0].oidc[0].issuer

  tags = {
    Name = "interview-eks-oidc"
  }
}

# CloudWatch Log Group para EKS
resource "aws_cloudwatch_log_group" "eks" {
  name              = "/aws/eks/${var.cluster_name}/cluster"
  retention_in_days = 1

  tags = {
    Name = "interview-eks-logs"
  }
}
