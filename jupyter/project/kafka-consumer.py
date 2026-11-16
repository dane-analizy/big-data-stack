from confluent_kafka import Consumer

from utils.config import load_config

# Ustawienia połączenia, topiku i grupy konsumentów.
config = load_config("./config.yaml")["kafka"]
broker = f'{config["host"]}:{config["port"]}'
topic = config["topic"]

consumer = Consumer(
    {
        "bootstrap.servers": broker,
        "group.id": config["group-id"],
        "auto.offset.reset": config["auto-offset-reset"],
        "enable.auto.commit": config["enable-auto-commit"],
    }
)

# Zapisz się do topiku i zacznij odbierać komunikaty.
consumer.subscribe([topic])

try:
    while True:
        message = consumer.poll(1.0)

        # Jeśli przez sekundę nie ma wiadomości, sprawdź ponownie.
        if message is None:
            continue
        if message.error():
            print(f"Błąd konsumenta: {message.error()}")
            continue

        # Odczytana wartość jest w bajtach; dekodujemy ją jako tekst UTF-8.
        print(message.value().decode("utf-8"))
except KeyboardInterrupt:
    print("Zatrzymano konsumenta.")
finally:
    # Zamknij konsumenta i zwolnij jego zasoby.
    consumer.close()
