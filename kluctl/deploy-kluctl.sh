#!/bin/bash -e

# Temporarily move AWS config to avoid conflicts
# if [ -d ~/.aws ]; then
#   mv ~/.aws ~/.aws.tmp
# fi

# Create namespace if it doesn't exist
kubectl create namespace strimzi-kafka --dry-run=client -o yaml | kubectl apply -f -

# Deploy complete Strimzi setup using kluctl
echo "Deploying Strimzi operator, Kafka cluster, and topics using kluctl..."
kluctl deploy --args-from-file values.yaml --yes -t strimzi-kafka

# # Restore AWS config
# if [ -d ~/.aws.tmp ]; then
#   mv ~/.aws.tmp ~/.aws
# fi

# Wait for operator to be ready
echo "Waiting for Strimzi operator to be ready..."
kubectl wait --for=condition=Ready pod -l name=strimzi-cluster-operator -n strimzi-kafka --timeout=300s

# Wait for Kafka cluster to be ready
echo "Waiting for Kafka cluster to be ready..."
kubectl wait kafka/my-cluster --for=condition=Ready --timeout=600s -n strimzi-kafka

# Wait for topics to be ready
echo "Waiting for topics to be ready..."
kubectl wait kafkatopic/revolver-ocelot --for=condition=Ready --timeout=120s -n strimzi-kafka
kubectl wait kafkatopic/psycho-mantis --for=condition=Ready --timeout=120s -n strimzi-kafka
kubectl wait kafkatopic/sniper-wolf --for=condition=Ready --timeout=120s -n strimzi-kafka
kubectl wait kafkatopic/liquid-snake --for=condition=Ready --timeout=120s -n strimzi-kafka

# Verification - show complete deployment
echo "=== Strimzi Deployment Status ==="
echo "Operator:"
kubectl get pods -l name=strimzi-cluster-operator -n strimzi-kafka
echo -e "\nKafka Cluster:"
kubectl get kafka -n strimzi-kafka
echo -e "\nKafka Pods:"
kubectl get pods -l strimzi.io/cluster=my-cluster -n strimzi-kafka
echo -e "\nTopics:"
kubectl get kafkatopics -n strimzi-kafka
