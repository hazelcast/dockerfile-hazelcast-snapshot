FROM maven:3-openjdk-8 AS build-env

ARG SOURCE_BRANCH=master

RUN apt-get update && apt-get install -y git
RUN git clone -b "$SOURCE_BRANCH" --depth 1 https://github.com/hazelcast/hazelcast.git
RUN mvn -f hazelcast/pom.xml clean install -DskipTests && \
  rm hazelcast/hazelcast-all/target/original-*.jar && \
  rm hazelcast/hazelcast-all/target/*-sources.jar && \
  mkdir /app && \
  mv hazelcast/hazelcast-all/target/hazelcast-all-*.jar /app/hazelcast-all.jar

FROM gcr.io/distroless/java:11
COPY --from=build-env /app /opt/hazelcast
WORKDIR /opt/hazelcast
CMD ["hazelcast-all.jar"]
