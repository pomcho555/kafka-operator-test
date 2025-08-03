#!/bin/bash -e

echo "=== Cleaning up Strimzi Kafka resources ==="

# Delete topics first
echo "Deleting Kafka topics..."
kubectl delete kafkatopics --all -n strimzi-kafka --ignore-not-found=true

# Delete Kafka cluster
echo "Deleting Kafka cluster..."
kubectl delete kafka my-cluster -n strimzi-kafka --ignore-not-found=true

# Wait for Kafka cluster to be fully deleted
echo "Waiting for Kafka cluster to be fully deleted..."
kubectl wait --for=delete kafka/my-cluster -n strimzi-kafka --timeout=300s 2>/dev/null || true

# Delete any remaining Kafka-related resources
echo "Cleaning up remaining Kafka resources..."
kubectl delete pods,services,configmaps,secrets,pvc -l strimzi.io/cluster=my-cluster -n strimzi-kafka --ignore-not-found=true

# Delete any persistent volumes (if using dynamic provisioning)
echo "Cleaning up persistent volumes..."
kubectl delete pv -l strimzi.io/cluster=my-cluster --ignore-not-found=true

echo "✅ Strimzi Kafka resources cleanup completed!"
echo "Note: This script only removes Kafka resources, not the operator itself."
echo "To remove the operator, run: ./cleanup-strimzi-operator.sh"