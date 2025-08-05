# Kluctl Complete Strimzi Deployment

This directory contains a complete kluctl-based approach to deploy the entire Strimzi stack: operator, Kafka cluster, and topics.

## Files

- `kluctl.yaml` - Complete deployment configuration (operator → cluster → topics)
- `values.yaml` - Cluster and topic definitions
- `templates/operator/` - Strimzi operator templates
- `templates/cluster/` - Kafka cluster templates  
- `templates/kafka-topics.yaml` - Topic templates
- `deploy-kluctl.sh` - Complete deployment script

## Benefits

- **Complete automation**: Single command deploys everything
- **Proper sequencing**: Operator → Cluster → Topics with barriers
- **Template-based**: All resources generated from templates
- **Configurable**: Modify cluster and topics in values.yaml
- **Consistent**: All resources follow the same patterns

## Usage

1. Modify topics in `values.yaml` if needed
2. Deploy topics:
   ```bash
   cd kluctl
   ./deploy-kluctl.sh
   ```

## Adding New Topics

Just add to the `topics` array in `values.yaml`:

```yaml
topics:
  - name: new-boss-topic
    partitions: 10
    replicas: 2
    retention_ms: 86400000
    min_insync_replicas: 2
```