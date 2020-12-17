FROM maven:3-openjdk-8 AS build-env

ARG SOURCE_BRANCH=master

RUN apt-get update && apt-get install -y git
RUN git clone -b "$SOURCE_BRANCH" --depth 1 https://github.com/hazelcast/hazelcast.git
RUN mvn -B -f hazelcast/pom.xml clean install -DskipTests && \
  rm hazelcast/hazelcast-all/target/original-*.jar && \
  rm hazelcast/hazelcast-all/target/*-sources.jar && \
  mkdir /app && \
  mv hazelcast/hazelcast-all/target/hazelcast-all-*.jar /app/hazelcast-all.jar

# https://github.com/GoogleContainerTools/distroless/tree/master/java
# https://github.com/GoogleContainerTools/distroless/blob/master/examples/java/Dockerfile

FROM gcr.io/distroless/java:11
COPY --from=build-env /app /opt/hazelcast
WORKDIR /opt/hazelcast
ENTRYPOINT ["/usr/bin/java", \
  "--add-modules", "java.se", \
  "--add-exports", "java.base/jdk.internal.ref=ALL-UNNAMED", \
  "--add-opens", "java.base/java.lang=ALL-UNNAMED", \
  "--add-opens", "java.base/java.nio=ALL-UNNAMED", \
  "--add-opens", "java.base/sun.nio.ch=ALL-UNNAMED", \
  "--add-opens", "java.management/sun.management=ALL-UNNAMED", \
  "--add-opens", "jdk.management/com.sun.management.internal=ALL-UNNAMED" ]

CMD ["-jar", "hazelcast-all.jar"]
