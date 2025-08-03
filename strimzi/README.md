# Strimzi Kafka Setup

This directory contains the Strimzi Kafka operator setup with the same configuration as the Bitnami deployment.

## Files

- `kafka-cluster.yaml` - Kafka cluster definition with 2 replicas
- `*-topic.yaml` - Topic definitions for all Metal Gear bosses
- `deploy-strimzi.sh` - Deployment script

## Configuration

- **Namespace**: `strimzi-kafka`
- **Cluster**: `my-cluster`
- **Replicas**: 2
- **Partitions**: 10 per topic
- **Retention**: 24 hours (86400000ms)
- **Min ISR**: 2

## Topics

- revolver-ocelot
- psycho-mantis
- sniper-wolf
- liquid-snake

## Usage

1. Deploy everything:
   ```bash
   ./deploy-strimzi.sh
   ```

2. Check cluster status:
   ```bash
   kubectl get kafka -n strimzi-kafka
   ```

3. List topics:
   ```bash
   kubectl get kafkatopics -n strimzi-kafka
   ```

## Test messaging

```sh
kubectl -n strimzi-kafka run kafka-producer -ti --image=quay.io/strimzi/kafka:0.47.0-kafka-4.0.0 --rm=true --restart=Never -- bin/kafka-console-producer.sh --bootstrap-server my-cluster-kafka-bootstrap:9092 --topic psycho-mantis

# Type whatever message
If you don't see a command prompt, try pressing enter.
>This is Major Tom, Ground Control.
```

```sh
kubectl -n strimzi-kafka run kafka-consumer -ti --image=quay.io/strimzi/kafka:0.47.0-kafka-4.0.0 --rm=true --restart=Never -- bin/kafka-console-consumer.sh --bootstrap-server my-cluster-kafka-bootstrap:9092 --topic psycho-mantis --from-beginning

>This is Major Tom, Ground Control.
```

## References
https://strimzi.io/quickstarts/
