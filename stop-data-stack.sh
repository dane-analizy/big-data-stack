#!/usr/bin/env bash
set -e

echo "🚀 Uruchamianie środowiska danych (Hadoop + Kafka + Mongo + Spark + NiFi)..."

# ========== KONFIGURACJA ==========
NETWORK_NAME="data-net"
HADOOP_COMPOSE="./hadoop/docker-compose.yaml"
KAFKA_COMPOSE="./kafka/docker-compose.yaml"
MONGO_COMPOSE="./mongo/docker-compose.yaml"
SPARK_COMPOSE="./spark/docker-compose.yaml"
NIFI_COMPOSE="./nifi/docker-compose.yaml"
JUPYTER_COMPOSE="./jupyter/docker-compose.yaml"

docker compose -f $JUPYTER_COMPOSE down
docker compose -f $HADOOP_COMPOSE down
docker compose -f $KAFKA_COMPOSE down
docker compose -f $MONGO_COMPOSE down
docker compose -f $SPARK_COMPOSE down
docker compose -f $NIFI_COMPOSE down
