#!/usr/bin/env powershell
$ErrorActionPreference = "Stop"

Write-Host "Zatrzymywanie srodowiska danych (Hadoop + Kafka + Mongo + Spark + NiFi + Jupyter)..." -ForegroundColor Yellow

# ========== KONFIGURACJA ==========
$NETWORK_NAME = "data-net"
$HADOOP_COMPOSE = ".\hadoop\docker-compose.yaml"
$KAFKA_COMPOSE = ".\kafka\docker-compose.yaml"
$MONGO_COMPOSE = ".\mongo\docker-compose.yaml"
$SPARK_COMPOSE = ".\spark\docker-compose.yaml"
$NIFI_COMPOSE = ".\nifi\docker-compose.yaml"
$JUPYTER_COMPOSE = ".\jupyter\docker-compose.yaml"

# ========== STOP SERWISOW ==========
Write-Host ""
Write-Host "Zatrzymywanie Jupyter Lab..."
try {
    docker compose -f $JUPYTER_COMPOSE down
} catch {
    Write-Host "Ostrzezenie przy zatrzymywaniu Jupyter: $_"
}

Write-Host "Zatrzymywanie Hadoop..."
try {
    docker compose -f $HADOOP_COMPOSE down
} catch {
    Write-Host "Ostrzezenie przy zatrzymywaniu Hadoop: $_"
}

Write-Host "Zatrzymywanie Kafka..."
try {
    docker compose -f $KAFKA_COMPOSE down
} catch {
    Write-Host "Ostrzezenie przy zatrzymywaniu Kafka: $_"
}

Write-Host "Zatrzymywanie MongoDB..."
try {
    docker compose -f $MONGO_COMPOSE down
} catch {
    Write-Host "Ostrzezenie przy zatrzymywaniu MongoDB: $_"
}

Write-Host "Zatrzymywanie Spark..."
try {
    docker compose -f $SPARK_COMPOSE down
} catch {
    Write-Host "Ostrzezenie przy zatrzymywaniu Spark: $_"
}

Write-Host "Zatrzymywanie NiFi..."
try {
    docker compose -f $NIFI_COMPOSE down
} catch {
    Write-Host "Ostrzezenie przy zatrzymywaniu NiFi: $_"
}

Write-Host ""
Write-Host "Wszystkie serwisy zatrzymane."
