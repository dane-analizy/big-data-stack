https://hub.docker.com/r/apache/nifi

Na początek trzeba założyć katalogi z odpowiednimi uprawnieniami:

```bash
mkdir -p ./data/nifi/flowfile_repository
mkdir -p ./data/nifi/content_repository
mkdir -p ./data/nifi/provenance_repository
mkdir -p ./data/nifi/database_repository
mkdir -p ./data/nifi/state
sudo chown -R 1000:1000 ./data/nifi
```

jak zdobyć login i hasło:

`docker logs nifi | grep Generated`


dostęp via www: `https://localhost:8443/nifi`