FROM eclipse-temurin:11
RUN mkdir -p /srv/photon

ADD https://github.com/komoot/photon/releases/download/0.4.2/photon-0.4.2.jar /srv/photon
ADD https://download1.graphhopper.com/public/extracts/by-country-code/co/photon-db-co-latest.tar.bz2 /srv/photon

RUN \  
  bzip2 -cd /srv/photon/photon-db-co-latest.tar.bz2 && \
  tar x /srv/photon/photon-db-co-latest.tar

EXPOSE 2322
CMD ["java", "-Xmx8G", "-jar", "/srv/photon/photon-0.4.2.jar", "-cors-any" ]
