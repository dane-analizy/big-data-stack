#!/usr/bin/env powershell
$ErrorActionPreference = "Stop"

Write-Host "Uruchamianie srodowiska danych (Hadoop + Kafka + Mongo + Spark + NiFi + Jupyter)..."

# ========== KONFIGURACJA ==========
$NETWORK_NAME = "data-net"
$HADOOP_COMPOSE = ".\hadoop\docker-compose.yaml"
$KAFKA_COMPOSE = ".\kafka\docker-compose.yaml"
$MONGO_COMPOSE = ".\mongo\docker-compose.yaml"
$SPARK_COMPOSE = ".\spark\docker-compose.yaml"
$NIFI_COMPOSE = ".\nifi\docker-compose.yaml"
$JUPYTER_COMPOSE = ".\jupyter\docker-compose.yaml"

# ========== TWORZENIE SIECI ==========
Write-Host "Tworzenie sieci Docker: $NETWORK_NAME"
$networkExists = docker network ls --format "{{.Name}}" | Select-String "^$NETWORK_NAME$"
if (-not $networkExists) {
    docker network create $NETWORK_NAME | Out-Null
}

# ========== URUCHAMIANIE HADOOP ==========
Write-Host "Uruchamianie Hadoop..."
docker compose -f $HADOOP_COMPOSE up -d

Write-Host "Czekam na NameNode (20s)..."
Start-Sleep -Seconds 20

# Tworzenie katalogu w HDFS, ignorowanie ostrzezen log4j
try {
    docker exec namenode hdfs dfs -mkdir -p /user/hadoop 2>$null
} catch {
    Write-Host "Ostrzezenie HDFS zignorowane: $_"
}

# ========== URUCHAMIANIE KAFKA ==========
Write-Host "Uruchamianie Kafka..."
docker compose -f $KAFKA_COMPOSE up -d

Write-Host "Czekam na Kafka broker (10s)..."
Start-Sleep -Seconds 10

# ========== URUCHAMIANIE MONGO ==========
Write-Host "Uruchamianie MongoDB..."
docker compose -f $MONGO_COMPOSE up -d

# ========== URUCHAMIANIE SPARK ==========
Write-Host "Uruchamianie Spark..."
docker compose -f $SPARK_COMPOSE up -d

# ========== URUCHAMIANIE NIFI ==========
Write-Host "Uruchamianie NiFi..."
docker compose -f $NIFI_COMPOSE up -d

Start-Sleep -Seconds 20
Write-Host "Logi NiFi (szukaj hasla):"
docker logs nifi | Select-String "Generated"

# ========== TESTY SIECI ==========
Write-Host "Test polaczenia w sieci..."

Write-Host "Ping namenode..."
docker exec namenode ping -c1 namenode

Write-Host "Ping broker..."
docker exec broker ping -c1 broker

Write-Host "Ping mongo..."
docker exec mongo ping -c1 mongo


# ========== TEST HDFS ==========
Write-Host "Test HDFS:"
docker exec namenode hdfs dfs -ls /

# ========== TEST KAFKA ==========
Write-Host "Test Kafka - lista topicow:"
docker exec broker bash -c "/opt/kafka/bin/kafka-topics.sh --bootstrap-server broker:9092 --list || true"

# ========== URUCHAMIANIE JUPYTER LAB ==========
Write-Host "Uruchamianie Jupyter Lab..."
docker compose -f $JUPYTER_COMPOSE up -d

# ========== STATUS ==========
Write-Host "Status kontenerow:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

Write-Host ""
Write-Host "Dostepne uslugi:"
Write-Host " - Jupyter Lab:    http://localhost:8888"
Write-Host " - Hadoop UI:      http://localhost:9870"
Write-Host " - YARN UI:        http://localhost:8088"
Write-Host " - Spark Master:   http://localhost:8080"
Write-Host " - Spark Worker:   http://localhost:8081"
Write-Host " - Mongo Express:  http://localhost:8082 (admin / pass)"
Write-Host " - NiFi:          https://localhost:8443 (login admin / hasło w logach kontenera)"

Write-Host ""
Write-Host "Aby zatrzymac wszystkie serwisy: .\stop-data-stack.ps1"
