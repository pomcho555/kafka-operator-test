#!/bin/bash -e

REPLICAS=2
ISR=2
RETENTION_MS=86400000
PARTITIONS=10

topics=(
  "revolver-ocelot"
  "psycho-mantis"
  "sniper-wolf"
  "liquid-snake"
)


# Kafka cluster creation
helm install my-release oci://registry-1.docker.io/bitnamicharts/kafka

kubectl run kafka-client --restart='Never' --image docker.io/bitnami/kafka --command -- sleep infinity

# Get Kafka credentials from kubectl
KAFKA_PASSWORD=$(kubectl get secret my-release-kafka-user-passwords -o jsonpath='{.data.client-passwords}' | base64 -d | cut -d, -f1)

# Create client.properties file with SASL credentials
kubectl exec kafka-client -- bash -c "cat > /opt/bitnami/kafka/config/client.properties << EOF
security.protocol=SASL_PLAINTEXT
sasl.mechanism=PLAIN
sasl.jaas.config=org.apache.kafka.common.security.plain.PlainLoginModule required username=\"user\" password=\"$KAFKA_PASSWORD\";
EOF"

# Create topics using the variables and loop through topics array
for topic in "${topics[@]}"; do
  kubectl exec -i kafka-client -- bash << EOS
    kafka-topics.sh --create --bootstrap-server=my-release-kafka:9092 \
      --replication-factor $REPLICAS \
      --partitions $PARTITIONS \
      --topic $topic \
      --config retention.ms=$RETENTION_MS \
      --config min.insync.replicas=$ISR \
      --command-config /opt/bitnami/kafka/config/client.properties
EOS
done


# Verification - list all kafka topics
echo "List all bosses!"
kubectl  exec -i kafka-client -- bash << 'EOS'
  kafka-topics.sh --list --bootstrap-server=my-release-kafka:9092 --command-config /opt/bitnami/kafka/config/client.properties
EOS
