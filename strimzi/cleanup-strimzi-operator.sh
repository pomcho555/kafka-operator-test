#!/bin/bash -e

echo "=== Cleaning up Strimzi operator ==="

# Delete the operator deployment and related resources in the namespace
echo "Deleting Strimzi operator from namespace strimzi-kafka..."
kubectl delete deployment strimzi-cluster-operator -n strimzi-kafka --ignore-not-found=true
kubectl delete serviceaccount strimzi-cluster-operator -n strimzi-kafka --ignore-not-found=true
kubectl delete configmaps,secrets -l app=strimzi -n strimzi-kafka --ignore-not-found=true

# Delete cluster-scoped resources (CRDs, ClusterRoles, ClusterRoleBindings)
echo "Deleting Strimzi cluster-scoped resources..."
kubectl delete clusterroles.rbac.authorization.k8s.io strimzi-cluster-operator-global strimzi-cluster-operator-namespaced strimzi-cluster-operator-watched strimzi-entity-operator strimzi-kafka-broker strimzi-topic-operator --ignore-not-found=true

kubectl delete clusterrolebindings.rbac.authorization.k8s.io strimzi-cluster-operator strimzi-cluster-operator-kafka-broker-delegation strimzi-cluster-operator-kafka-client-delegation --ignore-not-found=true

# Delete CRDs
echo "Deleting Strimzi Custom Resource Definitions..."
kubectl delete crd kafkas.kafka.strimzi.io kafkatopics.kafka.strimzi.io kafkausers.kafka.strimzi.io kafkaconnects.kafka.strimzi.io kafkaconnectors.kafka.strimzi.io kafkamirrormakers.kafka.strimzi.io kafkamirrormaker2s.kafka.strimzi.io kafkabridges.kafka.strimzi.io kafkarebalances.kafka.strimzi.io strimzipodsets.core.strimzi.io --ignore-not-found=true

# Delete the namespace (optional - comment out if you want to keep the namespace)
echo "Deleting strimzi-kafka namespace..."
kubectl delete namespace strimzi-kafka --ignore-not-found=true

echo "✅ Strimzi operator cleanup completed!"
echo "All Strimzi components have been removed from the cluster."