resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "interview-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = [aws_subnet.private_1.id, aws_subnet.private_2.id]
  version         = aws_eks_cluster.main.version

  scaling_config {
    desired_size = var.node_desired_size
    max_size     = var.node_max_size
    min_size     = var.node_min_size
  }

  instance_types = ["t3.small"]

  tags = {
    Name = "interview-node-group"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_container_registry_policy
  ]
}

resource "aws_autoscaling_group_tag" "cluster_autoscaler_enabled" {
  autoscaling_group_name = aws_eks_node_group.main.resources[0].autoscaling_groups[0].name

  tag {
    key                 = "k8s.io/cluster-autoscaler/${var.cluster_name}"
    value               = "owned"
    propagate_at_launch = false
  }

  depends_on = [aws_eks_node_group.main]
}
