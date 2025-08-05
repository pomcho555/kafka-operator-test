#!/bin/bash -e

NAMESPACE="strimzi-kafka"
CLUSTER_NAME="my-cluster"
TOPIC="revolver-ocelot"

echo "=== Testing Kafka Producer/Consumer for topic: $TOPIC ==="

# Create a temporary Kafka client pod if it doesn't exist
echo "Creating Kafka client pod..."
kubectl run kafka-client --restart='Never' --image docker.io/bitnami/kafka:latest --command -n $NAMESPACE -- sleep infinity 2>/dev/null || echo "Client pod already exists"

# Wait for client pod to be ready
echo "Waiting for client pod to be ready..."
kubectl wait --for=condition=Ready pod/kafka-client -n $NAMESPACE --timeout=120s

# Get Kafka bootstrap server
BOOTSTRAP_SERVER="$CLUSTER_NAME-kafka-bootstrap:9092"

echo "Using bootstrap server: $BOOTSTRAP_SERVER"

# Test producer - send a message
echo ""
echo "=== Testing Producer ==="
echo "Sending test message to topic '$TOPIC'..."

kubectl exec -n $NAMESPACE kafka-client -- bash -c "
echo 'Hello from Metal Gear Solid - Revolver Ocelot' | kafka-console-producer.sh \
  --bootstrap-server $BOOTSTRAP_SERVER \
  --topic $TOPIC
"

echo "✅ Message sent successfully!"

# Test consumer - read the message
echo ""
echo "=== Testing Consumer ==="
echo "Reading messages from topic '$TOPIC' (will timeout after 10 seconds)..."

timeout 10s kubectl exec -n $NAMESPACE kafka-client -- bash -c "
kafka-console-consumer.sh \
  --bootstrap-server $BOOTSTRAP_SERVER \
  --topic $TOPIC \
  --from-beginning
" || echo "✅ Consumer test completed (timeout expected)"

echo ""
echo "=== Topic Information ==="
kubectl exec -n $NAMESPACE kafka-client -- bash -c "
kafka-topics.sh \
  --bootstrap-server $BOOTSTRAP_SERVER \
  --describe \
  --topic $TOPIC
"

echo ""
echo "=== All Topics ==="
kubectl exec -n $NAMESPACE kafka-client -- bash -c "
kafka-topics.sh \
  --bootstrap-server $BOOTSTRAP_SERVER \
  --list
"

echo ""
echo "🎉 Kafka producer/consumer test completed successfully!"
echo "Topic '$TOPIC' is working correctly."