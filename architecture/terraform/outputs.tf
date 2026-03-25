# ============================================================================
# OUTPUTS.TF - Valores de salida
# ============================================================================

output "cluster_name" {
  value       = aws_eks_cluster.main.name
  description = "EKS cluster name"
}

output "cluster_endpoint" {
  value       = aws_eks_cluster.main.endpoint
  description = "EKS cluster endpoint"
}

output "cluster_security_group_id" {
  value       = aws_security_group.eks_cluster.id
  description = "EKS cluster security group ID"
}

output "node_group_id" {
  value       = aws_eks_node_group.main.id
  description = "EKS node group ID"
}

output "ecr_backend_url" {
  value       = aws_ecr_repository.backend.repository_url
  description = "ECR backend repository URL"
}

output "ecr_frontend_url" {
  value       = aws_ecr_repository.frontend.repository_url
  description = "ECR frontend repository URL"
}

output "db_endpoint" {
  value       = aws_db_instance.postgres.endpoint
  description = "RDS database endpoint"
}

output "kubeconfig_command" {
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${aws_eks_cluster.main.name}"
  description = "Command to update kubeconfig"
}
