FROM eclipse-temurin:17
RUN mkdir -p /srv/photon

ADD https://github.com/komoot/photon/releases/download/0.4.4/photon-0.4.4.jar /srv/photon
# ADD https://download1.graphhopper.com/public/extracts/by-country-code/co/photon-db-co-latest.tar.bz2 /srv/photon

RUN apt-get update && apt-get install -y \
      pbzip2
      
RUN cd /srv/photon

RUN wget -O - https://download1.graphhopper.com/public/extracts/by-country-code/co/photon-db-co-latest.tar.bz2 | pbzip2 -cd | tar x

EXPOSE 2322
CMD ["java", "-Xmx8G", "-jar", "/srv/photon/photon-0.4.4.jar", "-cors-any" ]
