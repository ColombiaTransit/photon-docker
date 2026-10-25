#!/usr/bin/env bash
# Importeert de Photon-database als die er nog niet is (of FORCE_IMPORT=true) en start de server.
set -euo pipefail
cd /photon
DATA=/photon/photon_data

import_args=(-languages "$LANGUAGES")
[ -n "${COUNTRY_CODES}" ] && import_args+=(-country-codes "$COUNTRY_CODES")
[ -n "${EXTRA_TAGS}" ] && import_args+=(-extra-tags "$EXTRA_TAGS")

needs_import() {
  [ "${FORCE_IMPORT}" = "true" ] && return 0
  # Leeg volume (alleen het mountpunt) = nog geen database
  [ -z "$(ls -A "$DATA" 2>/dev/null)" ]
}

if needs_import; then
  echo "== Photon ${PHOTON_VERSION}: database importeren (bron: ${IMPORT_SOURCE})"
  # Altijd in een tijdelijke map importeren en daarna omwisselen: nooit over een bestaande DB heen.
  tmp=/photon/import_tmp
  rm -rf "$tmp" && mkdir -p "$tmp"
  case "${IMPORT_SOURCE}" in
    dump)
      echo "   dump: ${DUMP_URL}"
      wget -q -O - "${DUMP_URL}" | zstd -dc \
        | java ${JAVA_OPTS} -jar photon.jar import -data-dir "$tmp" -import-file - "${import_args[@]}"
      ;;
    nominatim)
      echo "   Nominatim: ${NOMINATIM_USER}@${NOMINATIM_HOST}:${NOMINATIM_PORT}/${NOMINATIM_DB}"
      java ${JAVA_OPTS} -jar photon.jar import -data-dir "$tmp" \
        -host "${NOMINATIM_HOST}" -port "${NOMINATIM_PORT}" -database "${NOMINATIM_DB}" \
        -user "${NOMINATIM_USER}" -password "${NOMINATIM_PASSWORD}" "${import_args[@]}"
      ;;
    *)
      echo "Onbekende IMPORT_SOURCE '${IMPORT_SOURCE}' (dump of nominatim)"; exit 1 ;;
  esac
  # Inhoud van het volume vervangen door de nieuwe database
  find "$DATA" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
  mv "$tmp"/photon_data/* "$DATA"/
  rm -rf "$tmp"
  echo "== Import klaar"
fi

echo "== Photon ${PHOTON_VERSION} starten op poort 2322"
exec java ${JAVA_OPTS} -jar photon.jar serve -data-dir /photon -listen-ip 0.0.0.0 -cors-any "$@"
