#!/bin/bash -e

echo "=== Fixing Strimzi operator permissions ==="

# Create additional RBAC for leader election
kubectl apply -f - <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: strimzi-cluster-operator-leader-election
  namespace: strimzi-kafka
rules:
- apiGroups: ["coordination.k8s.io"]
  resources: ["leases"]
  verbs: ["get", "list", "create", "update", "delete"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: strimzi-cluster-operator-leader-election
  namespace: strimzi-kafka
subjects:
- kind: ServiceAccount
  name: strimzi-cluster-operator
  namespace: strimzi-kafka
roleRef:
  kind: Role
  name: strimzi-cluster-operator-leader-election
  apiGroup: rbac.authorization.k8s.io
EOF

echo "✅ Permissions fixed - restarting operator..."

# Restart the operator to pick up new permissions
kubectl rollout restart deployment/strimzi-cluster-operator -n strimzi-kafka

echo "✅ Operator restarted. Waiting for it to be ready..."
kubectl wait --for=condition=Ready pod -l name=strimzi-cluster-operator -n strimzi-kafka --timeout=120s

echo "✅ Operator is ready!"