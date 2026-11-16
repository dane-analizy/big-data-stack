import json

from confluent_kafka import Producer
from utils.config import load_config

# Połącz się z brokerem i wybierz topik z konfiguracji.
config = load_config("./config.yaml")["kafka"]
broker = f"{config['host']}:{config['port']}"
topic = config["topic"]

producer = Producer({"bootstrap.servers": broker})

# Przykładowe komunikaty, które wyślemy do topiku.
messages = [
    {"event": "user_signup", "user_id": 1},
    {"event": "purchase", "user_id": 2, "amount": 29.99},
    {"event": "user_login", "user_id": 3},
]

for message in messages:
    # Kafka przesyła bajty, dlatego zamieniamy słownik na JSON i kodujemy do UTF-8.
    producer.produce(topic, json.dumps(message).encode("utf-8"))

# Poczekaj, aż wszystkie zakolejkowane komunikaty zostaną wysłane.
producer.flush()
