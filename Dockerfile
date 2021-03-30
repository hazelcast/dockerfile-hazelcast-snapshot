FROM maven:3-openjdk-16 AS build-env

ARG SOURCE_BRANCH=master

RUN git clone -b "experiments/5.0/uds" --depth 1 https://github.com/kwart/hazelcast.git
RUN mvn -B -f hazelcast/pom.xml clean install -DskipTests -Dcheckstyle.skip && \
  mkdir /app && \
  mv hazelcast/hazelcast/target/hazelcast-5.0-SNAPSHOT.jar /app/hazelcast.jar

# https://github.com/GoogleContainerTools/distroless/tree/master/java
# https://github.com/GoogleContainerTools/distroless/blob/master/examples/java/Dockerfile

FROM openjdk:16
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

CMD ["-jar", "hazelcast.jar"]
