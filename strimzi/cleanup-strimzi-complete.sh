#!/bin/bash -e

echo "=== Complete Strimzi Cleanup ==="
echo "This will remove all Strimzi components from your cluster."
echo ""

# Confirmation prompt
read -p "Are you sure you want to proceed? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cleanup cancelled."
    exit 1
fi

echo ""
echo "Starting complete Strimzi cleanup..."
echo ""

# Step 1: Clean up Kafka resources first
echo "Step 1/2: Cleaning up Kafka resources..."
$(dirname "$0")/cleanup-strimzi-resources.sh

echo ""
echo "Waiting 30 seconds for resources to be fully deleted..."
sleep 30

# Step 2: Clean up operator
echo "Step 2/2: Cleaning up Strimzi operator..."
$(dirname "$0")/cleanup-strimzi-operator.sh

echo ""
echo "🎉 Complete Strimzi cleanup finished!"
echo ""
echo "What was removed:"
echo "  ✅ All Kafka topics"
echo "  ✅ Kafka cluster (my-cluster)"
echo "  ✅ Persistent volumes and claims"
echo "  ✅ Strimzi operator"
echo "  ✅ Custom Resource Definitions"
echo "  ✅ Cluster roles and bindings"
echo "  ✅ Namespace (strimzi-kafka)"
echo ""
echo "Your cluster is now clean and ready for a fresh Strimzi deployment."