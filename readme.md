# Big Data Stack

Repozytorium uruchamia lokalne środowisko do nauki i testowania narzędzi Big Data w kontenerach Docker:

- Apache Hadoop (HDFS i YARN)
- Apache Kafka
- MongoDB i Mongo Express
- Apache Spark
- Apache NiFi
- JupyterLab z PySpark

Usługi są połączone wspólną siecią Dockera `data-net`. Kontenery komunikują się między sobą po nazwach, np. `namenode`, `broker` i `spark-master`. Nie trzeba instalować tych narzędzi bezpośrednio w systemie — potrzebny jest Docker.

> To środowisko deweloperskie. Jupyter nie wymaga tokenu, a część usług ma przykładowe dane logowania. Nie wystawiaj go do publicznej sieci ani nie używaj z poufnymi danymi.

## 1. Wymagania

Przed uruchomieniem przygotuj:

1. **Docker z obsługą Docker Compose v2** — polecenie `docker compose` (ze spacją) powinno działać.
   - **Windows:** zainstaluj i uruchom Docker Desktop. W ustawieniach włącz silnik WSL 2, jeśli jest dostępny.
   - **WSL 2:** w Docker Desktop włącz integrację z używaną dystrybucją WSL. Uruchamiaj polecenia z terminala tej dystrybucji.
   - **Linux:** zainstaluj Docker Engine i wtyczkę Docker Compose. Użytkownik powinien mieć uprawnienia do uruchamiania poleceń `docker`.
2. **Git**, jeśli repozytorium nie jest jeszcze pobrane.
3. Wolne porty: `7077`, `8080`–`8082`, `8443`, `8888`, `9000`, `9092`, `29092`, `9870` i `8088`.
4. Kilka GB wolnego miejsca na obrazy i dane kontenerów.

Sprawdź, czy Docker działa:

```text
docker --version
docker compose version
docker info
```

Jeśli `docker info` zgłasza błąd połączenia z daemonem, uruchom Docker Desktop (Windows/WSL) albo usługę Dockera (Linux), a następnie ponów test.

## 2. Pobierz repozytorium

Jeśli masz już repozytorium, przejdź do jego katalogu głównego — tego, w którym znajdują się `start-data-stack.sh` i `start-data-stack.ps1`.

W przeciwnym razie pobierz repozytorium i przejdź do jego katalogu:

```bash
git clone https://github.com/dane-analizy/big-data-stack.git
cd big-data-stack
```

W **WSL** najlepiej przechowywać i uruchamiać repozytorium w systemie plików WSL (np. w `~/projekty`), a nie w `/mnt/c`. Zwykle zapewnia to lepszą wydajność i mniej problemów z uprawnieniami plików.

## 3. Uruchom cały zestaw

Wybierz instrukcję dla terminala, którego używasz. Uruchamiaj skrypt z katalogu głównego repozytorium.

### Windows — PowerShell

Otwórz PowerShell w katalogu repozytorium i wykonaj:

```powershell
.\start-data-stack.ps1
```

Jeśli system blokuje uruchomienie skryptu, uruchom go z tymczasowym wyjątkiem dotyczącym tylko tego procesu:

```powershell
powershell -ExecutionPolicy Bypass -File .\start-data-stack.ps1
```

### WSL 2 — Bash

Otwórz terminal WSL, przejdź do katalogu repozytorium i wykonaj:

```bash
bash ./start-data-stack.sh
```

Upewnij się, że Docker Desktop działa i integracja z tą dystrybucją WSL jest włączona. WSL i Windows korzystają z tych samych mapowań portów — usługi otworzysz w przeglądarce Windows pod `http://localhost:...`.

### Linux — Bash

Otwórz terminal w katalogu repozytorium i wykonaj:

```bash
bash ./start-data-stack.sh
```

Jeśli użytkownik nie ma uprawnień do Dockera, skonfiguruj je zgodnie z dokumentacją swojej dystrybucji. Nie uruchamiaj skryptu przez `sudo`, jeśli nie jest to konieczne — może to utworzyć pliki repozytorium należące do administratora.

Skrypt tworzy zewnętrzną sieć `data-net`, a następnie uruchamia Hadoop, Kafka, MongoDB, Spark, NiFi i Jupyter. Przy pierwszym uruchomieniu Docker może pobierać obrazy, więc start potrwa dłużej. Nie zamykaj terminala, jeśli skrypt nadal wykonuje kroki lub zgłasza błąd.

## 4. Sprawdź, czy usługi działają

Po zakończeniu skryptu sprawdź status kontenerów:

```bash
docker ps
```

W PowerShell możesz użyć tego samego polecenia. Na liście powinny być m.in. `namenode`, `datanode`, `broker`, `mongo`, `spark-master`, `spark-worker`, `nifi` i `jupyter`.

Otwórz usługi w przeglądarce:

| Usługa | Adres | Uwagi |
|---|---|---|
| JupyterLab | [http://localhost:8888](http://localhost:8888) | Token logowania jest wyłączony. |
| Hadoop NameNode | [http://localhost:9870](http://localhost:9870) | Panel HDFS. |
| YARN ResourceManager | [http://localhost:8088](http://localhost:8088) | Panel YARN. |
| Spark Master | [http://localhost:8080](http://localhost:8080) | Panel klastra Spark. |
| Spark Worker | [http://localhost:8081](http://localhost:8081) | Panel workera. |
| Mongo Express | [http://localhost:8082](http://localhost:8082) | Panel MongoDB. |
| NiFi | [https://localhost:8443/nifi](https://localhost:8443/nifi) | Przeglądarka może ostrzec o certyfikacie HTTPS. |

Dane dostępowe:

- **NiFi:** użytkownik `admin`, hasło `admin123`.
- **MongoDB:** użytkownik `root`, hasło `example` (dostęp do MongoDB, np. z kontenera w sieci).
- **Mongo Express:** interfejs uruchamia się bez włączonego uwierzytelniania.

Adresy dla klientów:

- **Kafka z innego kontenera w `data-net`:** `broker:9092`.
- **Kafka z systemu hosta (Windows, WSL lub Linux):** `localhost:29092`.
- **HDFS z innego kontenera w `data-net`:** `hdfs://namenode:9000`.
- **HDFS z systemu hosta:** `hdfs://localhost:9000`.
- **Spark Master z innego kontenera:** `spark://spark-master:7077`.
- **Spark Master z systemu hosta:** `spark://localhost:7077`.

Nie zamieniaj adresów hosta z nazwami kontenerów: `localhost` oznacza bieżący kontener, gdy używasz go wewnątrz kontenera.

## 5. Wykonaj krótki test

Sprawdź, czy HDFS odpowiada:

```bash
docker exec namenode hdfs dfs -ls /
```

Sprawdź, czy broker Kafka odpowiada i może wyświetlić listę tematów:

```bash
docker exec broker bash -c "/opt/kafka/bin/kafka-topics.sh --bootstrap-server broker:9092 --list"
```

Aby przesłać przykładowy plik do HDFS, najpierw utwórz go w katalogu repozytorium.

**PowerShell:**

```powershell
Set-Content -Path .\sample.txt -Value "Witaj w HDFS"
docker cp .\sample.txt namenode:/tmp/sample.txt
docker exec namenode hdfs dfs -mkdir -p /user/hadoop
docker exec namenode hdfs dfs -put -f /tmp/sample.txt /user/hadoop/sample.txt
docker exec namenode hdfs dfs -cat /user/hadoop/sample.txt
```

**WSL lub Linux:**

```bash
printf 'Witaj w HDFS\n' > sample.txt
docker cp ./sample.txt namenode:/tmp/sample.txt
docker exec namenode hdfs dfs -mkdir -p /user/hadoop
docker exec namenode hdfs dfs -put -f /tmp/sample.txt /user/hadoop/sample.txt
docker exec namenode hdfs dfs -cat /user/hadoop/sample.txt
```

## 6. Użyj PySpark w JupyterLab

Otwórz JupyterLab pod adresem [http://localhost:8888](http://localhost:8888), utwórz notatnik Python i uruchom poniższy kod. W tym przykładzie Jupyter łączy się z masterem Spark i HDFS po nazwach usług w sieci Docker:

```python
from pyspark.sql import SparkSession

spark = (
    SparkSession.builder
    .master("spark://spark-master:7077")
    .appName("czytanie-z-HDFS")
    .getOrCreate()
)

df = spark.read.text("hdfs://namenode:9000/user/hadoop/sample.txt")
df.show(truncate=False)
```

Jeśli wcześniej nie przesłano pliku `sample.txt` do HDFS, wykonaj kroki z sekcji „Wykonaj krótki test”.

## 7. Zatrzymaj usługi

Zatrzymanie kontenerów nie usuwa zapisanych danych. Uruchom odpowiednie polecenie z katalogu głównego repozytorium:

**Windows — PowerShell:**

```powershell
.\stop-data-stack.ps1
```

**WSL 2 lub Linux — Bash:**

```bash
bash ./stop-data-stack.sh
```

Aby ponownie uruchomić środowisko, użyj skryptu startowego z sekcji 3.

> **Uwaga:** dane HDFS, Kafka, MongoDB i NiFi są przechowywane w wolumenach Dockera i pozostają po zatrzymaniu usług. Nie usuwaj wolumenów (`docker compose down -v`), jeśli chcesz zachować te dane.

## 8. Typowe problemy

- **Docker nie działa:** uruchom Docker Desktop albo usługę Docker Engine i sprawdź `docker info`.
- **Port jest już zajęty:** zamknij program korzystający z portu albo zmień mapowanie portu w odpowiednim pliku `docker-compose.yaml`.
- **Kontenery nie startują:** sprawdź `docker ps -a`, a potem logi, np. `docker logs namenode` lub `docker logs nifi`.
- **Usługa nie odpowiada od razu:** daj kontenerom czas na pierwsze uruchomienie; sprawdź jego logi i ponownie otwórz stronę.
- **Nie można połączyć się z Kafka:** używaj `broker:9092` wewnątrz sieci Docker, a `localhost:29092` z systemu hosta.
- **Kontener nie widzi innej usługi:** upewnij się, że wszystkie zestawy Compose zostały uruchomione i są podłączone do wspólnej sieci `data-net`. Skrypt startowy tworzy tę sieć automatycznie.
- **Dostęp do Jupyter lub Mongo Express z innego urządzenia:** te interfejsy są skonfigurowane do lokalnej pracy i nie mają włączonego logowania. Nie udostępniaj ich w niezaufanej sieci.
