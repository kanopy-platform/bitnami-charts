#!/bin/bash
declare -a arr=("valkey" "valkey-cluster" "vault" "victoriametrics")
# declare -a arr=("valkey" "valkey-cluster" "vault" "victoriametrics" "wavefront" "wavefront-adapter-for-istio" "wavefront-hpa-adapter" "wavefront-prometheus-storage-adapter" "whereabouts" "wildfly" "wordpress" "wordpress-intel" "zipkin" "zookeeper")

# declare -a arr=("rabbitmq" "rabbitmq-cluster-operator" "redis" "redis-cluster" "redmine" "schema-registry" "scylladb" "sealed-secrets" "seaweedfs" "solr" "sonarqube" "spark" "spring-cloud-dataflow" "suitecrm" "supabase" "superset" "tensorflow-resnet" "tomcat" "valkey" "valkey-cluster" "vault" "victoriametrics" "wavefront" "wavefront-adapter-for-istio" "wavefront-hpa-adapter" "wavefront-prometheus-storage-adapter" "whereabouts" "wildfly" "wordpress" "wordpress-intel" "zipkin" "zookeeper")


for i in "${arr[@]}"; do
    CHART_NAME="$i"
    FULL_CHART_NAME="bitnami/$CHART_NAME"
    TEMP_DIR="./temp-charts-2"
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
