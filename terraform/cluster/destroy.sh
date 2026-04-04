#!/bin/bash
# destroy.sh — safe teardown for the cluster layer
# Run from terraform/cluster directory: bash destroy.sh
set -e

echo "==> Step 1: Deleting Kubernetes Ingress to trigger ALB deletion..."
kubectl delete ingress --all -n devops-quiz 2>/dev/null || true

echo "==> Step 2: Waiting 90s for ALB controller to delete the ALB and ENIs..."
sleep 90

echo "==> Step 3: Confirming no ALBs remain..."
aws elbv2 describe-load-balancers \
  --region ap-south-1 \
  --query "LoadBalancers[?contains(LoadBalancerName,'devops-quiz') || contains(LoadBalancerName,'k8s-devopsqu')].LoadBalancerName" \
  --output text | cat

echo "==> Step 4: Uninstalling Helm release (ALB controller)..."
# This removes the ServiceAccount and breaks the OIDC trust on the IAM role
# so Terraform can delete the alb_irsa IAM role cleanly in the next step.
helm uninstall aws-load-balancer-controller -n kube-system 2>/dev/null || echo "Helm release not found — skipping"

echo "==> Step 5: Waiting 30s for ServiceAccount and OIDC session to clear..."
sleep 30

echo "==> Step 6: Running terraform destroy..."
terraform destroy -auto-approve

echo "==> Done. Cluster layer fully destroyed."
