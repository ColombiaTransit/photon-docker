# photon-docker

Docker-image voor [Photon](https://github.com/komoot/photon) (OSM-geocoder) met data van
Colombia. Wordt o.a. gebruikt door `geocode_points.py` in gtfs-redbus.

- Photon **1.3.0** (Java 21, ingebouwde OpenSearch). Andere versie: build-argument `PHOTON_VERSION`.
- De database zit niet in het image maar in het volume `/photon/photon_data`; bij de eerste
  start wordt hij geïmporteerd (daarna niet meer, tenzij `FORCE_IMPORT=true`).
- Bron: de wekelijkse Colombia-dump van GraphHopper (`DUMP_URL`, formaat 1.0, werkt met
  Photon ≥ 1.0.1). Nieuwere data: opnieuw importeren met `FORCE_IMPORT=true`.
- Talen: `LANGUAGES=es,en` (Spaanse namen doorzoekbaar met `lang=es`).

```bash
docker compose up -d                 # import (eerste keer ~10-30 min) en daarna server op :2322
curl "http://localhost:2322/api?q=terminal%20de%20transportes%20monteria&limit=3"
```

Geheugen: `JAVA_OPTS=-Xmx6G` is ruim voor Colombia; zorg dat de host meer vrij heeft
dan de heap (OpenSearch gebruikt ook buiten de heap geheugen).

Image bouwen gebeurt door de GitHub Action bij elke push (`mvanlaar/photon-docker:latest`
en `:<photon-versie>`).
