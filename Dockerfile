# Photon (OSM-geocoder, OpenSearch-gebaseerd) voor Colombia.
#
# De database zit NIET meer in het image: bij de eerste start wordt hij in /photon/photon_data
# (een volume) geïmporteerd, uit een JSON-dump (standaard: wekelijkse Colombia-dump van
# GraphHopper) of uit een Nominatim-database (bv. gevuld met de Geofabrik-export).
# Zie README.md en docker-compose.yml.
FROM eclipse-temurin:21-jre

ARG PHOTON_VERSION=1.3.0
ENV PHOTON_VERSION=${PHOTON_VERSION}

RUN apt-get update \
 && apt-get install -y --no-install-recommends wget zstd ca-certificates \
 && rm -rf /var/lib/apt/lists/* \
 && mkdir -p /photon \
 && wget -q -O /photon/photon.jar \
      "https://github.com/komoot/photon/releases/download/${PHOTON_VERSION}/photon-${PHOTON_VERSION}.jar"

COPY entrypoint.sh /photon/entrypoint.sh
RUN chmod +x /photon/entrypoint.sh

WORKDIR /photon
VOLUME ["/photon/photon_data"]
EXPOSE 2322

# Standaardinstellingen (te overschrijven met environment-variabelen)
ENV JAVA_OPTS="-Xmx6G" \
    IMPORT_SOURCE="dump" \
    DUMP_URL="https://download1.graphhopper.com/public/south-america/colombia/photon-dump-colombia-1.0-latest.jsonl.zst" \
    LANGUAGES="es,en" \
    COUNTRY_CODES="co" \
    EXTRA_TAGS="" \
    NOMINATIM_HOST="nominatim" \
    NOMINATIM_PORT="5432" \
    NOMINATIM_DB="nominatim" \
    NOMINATIM_USER="nominatim" \
    NOMINATIM_PASSWORD="" \
    FORCE_IMPORT="false"

HEALTHCHECK --interval=60s --timeout=10s --start-period=30m --retries=3 \
  CMD wget -q -O /dev/null "http://127.0.0.1:2322/api?q=bogota&limit=1" || exit 1

ENTRYPOINT ["/photon/entrypoint.sh"]
