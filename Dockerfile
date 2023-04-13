FROM eclipse-temurin:17
RUN mkdir -p /opt/app
RUN mkdir -p /var/opentripplanner
ADD https://github.com/opentripplanner/OpenTripPlanner/releases/download/v2.2.0/otp-2.2.0-shaded.jar /opt/app
ADD https://download.geofabrik.de/south-america/colombia-latest.osm.pbf /var/opentripplanner
ADD https://storage.googleapis.com/gtfs-estaticos/GTFS-2023-10-01.zip /var/opentripplanner
EXPOSE 8080
CMD ["java", "-Xmx8G", "-jar", "/opt/app/otp-2.2.0-shaded.jar", "--build", "--serve", "/var/opentripplanner" ]
