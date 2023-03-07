FROM eclipse-temurin:11-jdk AS overlay

RUN mkdir -p cas-overlay
COPY ./src cas-overlay/src/
COPY ./gradle/ cas-overlay/gradle/
COPY ./gradlew ./build.gradle ./gradle.properties /cas-overlay/

RUN mkdir -p ~/.gradle \
    && echo "org.gradle.daemon=false" >> ~/.gradle/gradle.properties \
    && echo "org.gradle.configureondemand=true" >> ~/.gradle/gradle.properties \
    && cd cas-overlay \
    && chmod 750 ./gradlew \
    && ./gradlew --version;

RUN cd cas-overlay \
    && ./gradlew clean build --parallel --no-daemon;

FROM eclipse-temurin:11-jdk AS cas

LABEL "Organization"="Apereo"
LABEL "Description"="Apereo CAS"

RUN cd / \
    && mkdir -p cas-overlay;

COPY --from=overlay cas-overlay/build/libs/cas.war cas-overlay/

EXPOSE 8080 8443

ENV PATH $PATH:$JAVA_HOME/bin:.

WORKDIR /cas-overlay
ENTRYPOINT ["java", "-server", "-noverify", "-Xmx512M", "-jar", "cas.war"]
