**UWAGA** WERSJA ROBOCZA! Dokumentacja poniżej w dużej mierze napisana przez AI i nie weryfikowana!

# 1) Pomysł w pigułce

* Utwórz jedną **zewnętrzną** sieć dockera (np. `data-net`) i dołącz do niej *wszystkie* compose’y / kontenery. Wtedy nazwy kontenerów (np. `namenode`, `broker`, `mongo`) będą rozwiązywane wewnątrz sieci.
* Dla usług które mają być dostępne z **hosta** (Jupyter notebook) wystaw dodatkowo porty na hosta (np. HDFS RPC 9000, Kafka zewnętrzny port, Spark 7077).
* Skonfiguruj **Kafka** tak, by miała dwóch listenerów (wewnętrzny dla kontenerów i zewnętrzny dla hosta) — to częste źródło problemów.
* Dla **Hadoop** zamontuj/udostępnij pliki konfiguracyjne (`core-site.xml`/`hdfs-site.xml`) albo ustaw właściwe `fs.defaultFS`, żeby klienci z hosta mogli wskazać `hdfs://localhost:9000`.
* Jeśli chcesz używać **PySpark z hosta**: najpewniejsza opcja — odpalić Spark w Docker (w tej samej sieci) i wystawić `7077` na host, wtedy Jupyter z hosta łączy się do `spark://localhost:7077` i odczytuje pliki z HDFS (np. `hdfs://localhost:9000/...`).

---

# 2) Utwórz zewnętrzną sieć (jednorazowo)

```bash
docker network create data-net
```

---

# 3) Jak uruchomić cały stack — przykładowa kolejność

1. `docker network create data-net` (jeśli nie zrobione)
2. W katalogu Hadoop: `docker-compose -f docker-compose-hadoop.yml up -d`
3. Sprawdź HDFS UI: `http://localhost:9870`
4. W katalogu Kafka: `docker-compose -f docker-compose-kafka.yml up -d`
5. W katalogu Mongo: `docker-compose -f docker-compose-mongo.yml up -d`
6. Uruchom NiFi: `docker run --name nifi --network data-net -p 8443:8443 -d apache/nifi:latest`
7. (Opcjonalnie) Spark: `docker-compose -f docker-compose-spark.yml up -d`

Sprawdzenia:

```bash
# Czy kontenery są w sieci?
docker network inspect data-net

# Ping z krótkiego kontenera:
docker run --rm --network data-net alpine ping -c 2 namenode

# Sprawdź Kafka z sieci:
docker run --rm --network data-net edenhill/kafkacat kafkacat -b broker:9092 -L
```

---

# 4) Jak z Jupyter (host) odczytać dane z HDFS przy pomocy PySpark

Załóżmy, że:

* masz Spark master wystawiony na `localhost:7077`,
* namenode RPC zmapowany na `localhost:9000`.

W Jupyter (na hoście) zainstaluj pyspark:

```bash
pip install pyspark
```

Przykład w notatniku:

```python
from pyspark.sql import SparkSession

spark = SparkSession.builder \
    .master("spark://localhost:7077") \
    .appName("read-hdfs") \
    .config("spark.hadoop.fs.defaultFS", "hdfs://localhost:9000") \
    .getOrCreate()

# odczyt tekstu z HDFS
df = spark.read.text("hdfs://localhost:9000/user/hadoop/test.txt")
df.show()
```

Jeśli nie używasz Sparka uruchomionego w Docker i chcesz uruchamiać Spark *lokalnie* (na hoście) musisz:

* albo zainstalować Hadoop client / native libs na hoście i ustawić `HADOOP_CONF_DIR` (powinna tam być kopia `core-site.xml` wskazująca `hdfs://localhost:9000`),
* albo użyć Spark w Docker (szybsze i mniej problemów).

---

# 5) Testy prostych operacji HDFS (przykłady)

Dodaj plik do HDFS:

```bash
# skopiuj plik z hosta do kontenera namenode
docker cp ./localfile.txt namenode:/tmp/localfile.txt

# umieść w HDFS
docker exec -it namenode hdfs dfs -mkdir -p /user/hadoop
docker exec -it namenode hdfs dfs -put /tmp/localfile.txt /user/hadoop/test.txt

# sprawdź
docker exec -it namenode hdfs dfs -ls /user/hadoop
```

---

# 6) Najczęstsze problemy i wskazówki

* **`localhost` vs `container name`**: pamiętaj — `namenode` (container name) działa wewnątrz sieci `data-net`. Host nie widzi `namenode` bez mapowania portu. Dlatego wystaw porty (9000, 9870).
* **Kafka — advertised.listeners**: jeżeli źle ustawisz `advertised.listeners`, klienci (host/kontenery) nie będą mogli się podłączyć. Rekomendowany wzorzec to *internal* + *external* listener.
* **Uprawnienia do wolumenów/SELinux** przy mapowaniu katalogów (Hadoop zapisuje na dysku) — czasem trzeba dopasować uprawnienia.
* **Wersje**: dopasuj wersje Spark/Hadoop/iceberg/klientów — niezgodność wersji może powodować błędy.
* **Jeśli chcesz Iceberg**: dodaj Spark z odpowiednimi JARami Iceberga i zmień `spark-submit`/`SparkSession` tak, żeby ustawiać katalog (HadoopCatalog/HiveCatalog).

---

# 7) Skrypt startowy

1️⃣ tworzy wspólną sieć Dockera (`data-net`),
2️⃣ uruchamia po kolei Twój Hadoop, Kafka, MongoDB, Spark i NiFi,
3️⃣ czeka, aż kluczowe serwisy wstaną,
4️⃣ wykonuje testy połączenia (`ping`, `hdfs dfs -ls`, `kafka-topics`),
5️⃣ na koniec pokazuje status.

[Kompletny skrypt](start-data-stack.sh) - możesz go uruchomić np. `bash start-data-stack.sh`
