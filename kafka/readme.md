# Apache Kafka

## Uruchomienie w Dockerze

- obraz z [apache/kafka](https://hub.docker.com/r/apache/kafka)
- start: `docker compose up -d`
- stop: `docker compose down`
- podpięcie się pod kontener: \
`docker exec --workdir /opt/kafka/bin/ -it broker bash`

## 🧩 **Apache Kafka – podstawowe komendy**

### 🔧 **Zarządzanie topicami**

| Cel                             | Komenda                                                                                                                 | Opis                                                        |
| ------------------------------- | ----------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------- |
| **Lista topiców**               | `./kafka-topics.sh --bootstrap-server localhost:9092 --list`                                                            | Wyświetla wszystkie istniejące topiki.                      |
| **Utworzenie topicu**           | `./kafka-topics.sh --bootstrap-server localhost:9092 --create --topic test-topic --partitions 3 --replication-factor 1` | Tworzy nowy topic z 3 partycjami i 1 repliką.               |
| **Szczegóły topicu**            | `./kafka-topics.sh --bootstrap-server localhost:9092 --describe --topic test-topic`                                     | Pokazuje konfigurację i liderów partycji.                   |
| **Usunięcie topicu**            | `./kafka-topics.sh --bootstrap-server localhost:9092 --delete --topic test-topic`                                       | Usuwa topic (musi być włączone `delete.topic.enable=true`). |
| **Zwiększenie liczby partycji** | `./kafka-topics.sh --bootstrap-server localhost:9092 --alter --topic test-topic --partitions 6`                         | Dodaje partycje do istniejącego topicu.                     |

---

### 💬 **Producent i konsument**

| Cel                                 | Komenda                                                                                               | Opis                                              |
| ----------------------------------- | ----------------------------------------------------------------------------------------------------- | ------------------------------------------------- |
| **Producent (terminal)**            | `./kafka-console-producer.sh --bootstrap-server localhost:9092 --topic test-topic`                    | Otwiera konsolę do wysyłania wiadomości.          |
| **Producent z pliku**               | `cat dane.txt \| ./kafka-console-producer.sh --bootstrap-server localhost:9092 --topic test-topic`    | Wysyła linie z pliku jako wiadomości.             |
| **Konsument (terminal)**            | `./kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test-topic --from-beginning`   | Wyświetla wszystkie wiadomości od początku.       |
| **Konsument tylko nowe wiadomości** | `./kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test-topic`                    | Pokazuje tylko nowe dane po uruchomieniu.         |
| **Konsument w grupie**              | `./kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test-topic --group test-group` | Subskrybuje topic jako członek grupy konsumentów. |

---

### 🔄 **Zarządzanie grupami konsumentów**

| Cel                                  | Komenda                                                                                                                                      | Opis                                          |
| ------------------------------------ | -------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------- |
| **Lista grup**                       | `./kafka-consumer-groups.sh --bootstrap-server localhost:9092 --list`                                                                        | Pokazuje wszystkie grupy konsumentów.         |
| **Status grupy**                     | `./kafka-consumer-groups.sh --bootstrap-server localhost:9092 --describe --group test-group`                                                 | Pokazuje offsety, lag i przypisania partycji. |
| **Reset offsetów (np. od początku)** | `./kafka-consumer-groups.sh --bootstrap-server localhost:9092 --group test-group --topic test-topic --reset-offsets --to-earliest --execute` | Resetuje offsety grupy do początku topicu.    |
| **Usunięcie grupy**                  | `./kafka-consumer-groups.sh --bootstrap-server localhost:9092 --delete --group test-group`                                                   | Usuwa grupę konsumentów.                      |

---

### 🗂️ **Operacje na wiadomościach i offsetach**

| Cel                                               | Komenda                                                                                                                            | Opis                                    |
| ------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------- |
| **Sprawdzenie offsetów**                          | `./kafka-run-class.sh kafka.tools.GetOffsetShell --broker-list localhost:9092 --topic test-topic`                                  | Pokazuje aktualne offsety dla partycji. |
| **Wyświetlenie wiadomości z konkretnej partycji** | `./kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test-topic --partition 0 --offset 10 --max-messages 5`      | Pobiera wiadomości od offsetu 10.       |
| **Eksport wiadomości do pliku**                   | `./kafka-console-consumer.sh --bootstrap-server localhost:9092 --topic test-topic --from-beginning --timeout-ms 5000 > output.txt` | Zapisuje wiadomości do pliku.           |

---

### ⚙️ **Broker, konfiguracja i narzędzia administracyjne**

| Cel                                 | Komenda                                                                                                                                        | Opis                                                         |
| ----------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------ |
| **Lista brokerów**                  | `./zookeeper-shell.sh localhost:2181 ls /brokers/ids`                                                                                          | (jeśli Zookeeper włączony) pokazuje identyfikatory brokerów. |
| **Sprawdzenie statusu klastra**     | `./kafka-broker-api-versions.sh --bootstrap-server localhost:9092`                                                                             | Pokazuje wersje API brokerów.                                |
| **Sprawdzenie konfiguracji topicu** | `./kafka-configs.sh --bootstrap-server localhost:9092 --entity-type topics --entity-name test-topic --describe`                                | Pokazuje ustawienia topicu.                                  |
| **Zmienianie konfiguracji topicu**  | `./kafka-configs.sh --bootstrap-server localhost:9092 --entity-type topics --entity-name test-topic --alter --add-config retention.ms=3600000` | Ustawia czas retencji wiadomości (1h).                       |

---

### 🧹 **Porządki i diagnostyka**

| Cel                                          | Komenda                                 | Opis                                   |
| -------------------------------------------- | --------------------------------------- | -------------------------------------- |
| **Sprawdzenie logów brokera**                | `tail -f /opt/kafka/logs/server.log`    | Podgląd logów działania brokera.       |
| **Czyszczenie danych lokalnych (np. w dev)** | `rm -rf /tmp/kafka-logs /tmp/zookeeper` | Usuwa lokalne dane Kafki i Zookeepera. |
| **Sprawdzenie wersji Kafki**                 | `./kafka-topics.sh --version`           | Wyświetla wersję narzędzi Kafki.       |
