#!/bin/bash -ex

# Create namespace
kubectl create namespace strimzi-kafka --dry-run=client -o yaml | kubectl apply -f -

# Install Strimzi operator (skip if already exists)
if ! kubectl get clusterrole strimzi-cluster-operator-watched &>/dev/null; then
  kubectl create -f 'https://strimzi.io/install/latest?namespace=strimzi-kafka' -n strimzi-kafka
else
  echo "Strimzi operator already installed, skipping..."
fi

# Wait for operator to be ready
kubectl wait --for=condition=Ready pod -l name=strimzi-cluster-operator -n strimzi-kafka --timeout=300s

# Deploy Kafka cluster
# Make sure kafka version is 4.0+ because zookeeper is removed after 4.0.
kubectl apply -f https://strimzi.io/examples/latest/kafka/kafka-single-node.yaml -n strimzi-kafka

# Wait for Kafka cluster to be ready
kubectl wait kafka/my-cluster --for=condition=Ready --timeout=300s -n strimzi-kafka

# Deploy all topics
kubectl apply -f ./revolver-ocelot-topic.yaml
kubectl apply -f ./psycho-mantis-topic.yaml
kubectl apply -f ./sniper-wolf-topic.yaml
kubectl apply -f ./liquid-snake-topic.yaml

# Wait for topics to be ready
kubectl wait kafkatopic/revolver-ocelot --for=condition=Ready --timeout=120s -n strimzi-kafka
kubectl wait kafkatopic/psycho-mantis --for=condition=Ready --timeout=120s -n strimzi-kafka
kubectl wait kafkatopic/sniper-wolf --for=condition=Ready --timeout=120s -n strimzi-kafka
kubectl wait kafkatopic/liquid-snake --for=condition=Ready --timeout=120s -n strimzi-kafka

# Verification - list all topics
echo "List all Metal Gear bosses (topics):"
kubectl get kafkatopics -n strimzi-kafka
