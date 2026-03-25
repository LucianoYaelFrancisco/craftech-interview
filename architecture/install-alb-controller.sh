#!/bin/bash
set -e

echo "Installing AWS Load Balancer Controller..."

if ! command -v helm &> /dev/null; then
    echo "Installing Helm..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
fi

# Agregar repo y actualizar
helm repo add eks https://aws.github.io/eks-charts 2>/dev/null || true
helm repo update

# Instalar el controller
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=interview-eks-cluster \
  --set serviceAccount.create=false \
  --set serviceAccount.name=aws-load-balancer-controller

kubectl rollout status deployment/aws-load-balancer-controller -n kube-system --timeout=5m || true

