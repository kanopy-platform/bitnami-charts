#!/bin/bash
declare -a arr=("elasticsearch" "envoy-gateway" "etcd" "external-dns")
# declare -a arr=("elasticsearch" "envoy-gateway" "etcd" "external-dns" "flink" "fluent-bit" "fluentd" "flux" "geode" "ghost" "gitea" "gitlab-runner" "grafana" "grafana-alloy" "grafana-k6-operator" "grafana-loki" "grafana-mimir" "grafana-operator" "grafana-tempo" "haproxy" "haproxy-intel" "harbor" "influxdb" "jaeger" "janusgraph" "jasperreports" "jenkins" "joomla" "jupyterhub" "kafka" "keycloak" "keydb" "kiam" "kibana" "kong" "kube-arangodb" "kube-prometheus" "kube-state-metrics" "kubeapps" "kuberay" "kubernetes-event-exporter" "logstash" "magento" "mariadb" "mariadb-galera" "mastodon" "matomo" "mediawiki" "memcached" "metallb" "metrics-server" "milvus" "minio" "minio-operator" "mlflow" "mongodb" "mongodb-sharded" "moodle" "multus-cni" "mxnet" "mysql" "nats" "neo4j" "nessie" "nginx" "nginx-ingress-controller" "nginx-intel" "node" "node-exporter" "oauth2-proxy" "odoo" "opencart" "opensearch" "osclass" "owncloud" "parse" "phpbb" "phpmyadmin" "pinniped" "postgresql" "postgresql-ha" "prestashop" "prometheus" "pytorch")

# need to redo: appsmith

for i in "${arr[@]}"; do
    CHART_NAME="$i"
    FULL_CHART_NAME="bitnami/$CHART_NAME"
    TEMP_DIR="./temp-charts"
    OUTPUT_DIR="./docs"

    mkdir -p "$TEMP_DIR"

    # Download all versions first
    helm search repo "$FULL_CHART_NAME" --versions --output json | \
    jq -r '.[].version' | \
    while read version; do
        echo "Processing version: $version"
        
        # Download and extract
        helm pull "$FULL_CHART_NAME" --version "$version" --untar --destination "$TEMP_DIR"
        
        # Get the extracted directory name
        CHART_DIR=$(find "$TEMP_DIR" -maxdepth 1 -type d -name "*$CHART_NAME*" | head -1)

        if [ -n "$CHART_DIR" ]; then
            # Repackage it
            helm package "$CHART_DIR" --destination "$OUTPUT_DIR"
            
            # Clean up extracted files
            rm -rf "$CHART_DIR"
        fi
    done
done
