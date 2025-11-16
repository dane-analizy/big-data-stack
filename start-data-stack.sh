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

# ========== TWORZENIE SIECI ==========
echo ""
echo "🔹 Tworzenie sieci Docker: $NETWORK_NAME"
docker network inspect "$NETWORK_NAME" >/dev/null 2>&1 || docker network create "$NETWORK_NAME"

# ========== URUCHAMIANIE HADOOP ==========
echo ""
echo "🔹 Uruchamianie Hadoop..."
docker compose -f "$HADOOP_COMPOSE" up -d

# czekamy aż namenode się podniesie
echo "⏳ Czekam aż NameNode wystartuje (ok. 20s)..."
sleep 20
docker exec namenode hdfs dfs -mkdir -p /user/hadoop || true

# ========== URUCHAMIANIE KAFKA ==========
echo ""
echo "🔹 Uruchamianie Kafka..."
docker compose -f "$KAFKA_COMPOSE" up -d

# czekamy aż broker wystartuje
echo "⏳ Czekam aż broker Kafka się uruchomi (ok. 10s)..."
sleep 10

# ========== URUCHAMIANIE MONGO ==========
echo ""
echo "🔹 Uruchamianie MongoDB..."
docker compose -f "$MONGO_COMPOSE" up -d

# ========== URUCHAMIANIE SPARK ==========
echo ""
echo "🔹 Uruchamianie Spark..."
docker compose -f "$SPARK_COMPOSE" up -d

# ========== URUCHAMIANIE NIFI ==========
echo ""
echo "🔹 Uruchamianie NiFi..."
docker compose -f "$NIFI_COMPOSE" up -d
sleep 20
echo ""
echo "🔥 User i password do NiFi znajdziesz w logach kontenera:"
docker logs nifi | grep Generated

# ========== TESTY ==========
echo ""
echo "✅ Test połączenia w sieci (namenode, broker, mongo)"
docker run --rm --network "$NETWORK_NAME" alpine sh -c "
  apk add --no-cache curl bind-tools >/dev/null
  echo 'Ping namenode:' && ping -c1 namenode
  echo 'Ping broker:' && ping -c1 broker
  echo 'Ping mongo:' && ping -c1 mongo
"

echo ""
echo "✅ Test HDFS:"
docker exec namenode hdfs dfs -ls /

echo ""
echo "✅ Test Kafka (lista topików):"
docker exec broker bash -c "/opt/kafka/bin/kafka-topics.sh --bootstrap-server broker:9092 --list || true"

# ========== URUCHAMIANIE JUPYTER LAB ==========
echo ""
echo "🔹 Uruchamianie Jupyter Lab..."
docker compose -f "$JUPYTER_COMPOSE" up -d

# ========== STATUS ==========
echo ""
echo "📊 Status kontenerów:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

echo ""
echo "✅ Wszystkie komponenty powinny być dostępne:"
echo " • Jupyter Lab:    → http://localhost:8888"
echo " • Hadoop UI:      → http://localhost:9870"
echo " • YARN UI:        → http://localhost:8088"
echo " • Spark Master UI → http://localhost:8080"
echo " • Spark Worker UI → http://localhost:8081"
echo " • Kafka broker:   → broker:9092"
echo " • Mongo UI:       → http://localhost:8082 (admin / pass)"
echo " • NiFi UI:        → https://localhost:8443 (login admin / hasło w logach kontenera)"
echo ""
echo ""
echo "🔥 Aby zatrzymać wszystkie serwisy:"
echo "   ./stop-data-stack.sh"
echo ""
echo "🔄 Aby zatrzymać pojedyncze serwisy:"
echo "   docker compose -f $HADOOP_COMPOSE down"
echo "   docker compose -f $KAFKA_COMPOSE down"
echo "   docker compose -f $MONGO_COMPOSE down"
echo "   docker compose -f $SPARK_COMPOSE down"
echo "   docker compose -f $NIFI_COMPOSE down"
