FROM maven:3-openjdk-16 AS build-env

RUN git clone -b "experiments/5.0/uds" --depth 1 https://github.com/vbekiaris/hazelcast.git
RUN mkdir /app && \
  mvn -B -f hazelcast/pom.xml clean install -DskipTests -Dcheckstyle.skip && \
  mv hazelcast/hazelcast/target/hazelcast-5.0-SNAPSHOT.jar /app/hazelcast.jar && \
  mvn -B -f hazelcast/jmh-benchmark/pom.xml clean install -DskipTests -Dcheckstyle.skip && \
  mv hazelcast/jmh-benchmark/target/test-app-5.0-SNAPSHOT.jar /app/ && \
  mvn -B -f hazelcast/jmh-benchmark/pom.xml clean install -DskipTests -Dcheckstyle.skip -Dversion.hazelcast=4.2 && \
  mv hazelcast/jmh-benchmark/target/test-app-4.2.jar /app/ && \
  mv ~/.m2/repository/com/hazelcast/hazelcast/4.2/hazelcast-4.2.jar /app/

# https://github.com/GoogleContainerTools/distroless/tree/master/java
# https://github.com/GoogleContainerTools/distroless/blob/master/examples/java/Dockerfile

FROM openjdk:16
COPY --from=build-env /app /opt/hazelcast
WORKDIR /opt/hazelcast

CMD [ "/usr/bin/java", \
  "--add-modules", "java.se", \
  "--add-exports", "java.base/jdk.internal.ref=ALL-UNNAMED", \
  "--add-opens", "java.base/java.lang=ALL-UNNAMED", \
  "--add-opens", "java.base/java.nio=ALL-UNNAMED", \
  "--add-opens", "java.base/sun.nio.ch=ALL-UNNAMED", \
  "--add-opens", "java.management/sun.management=ALL-UNNAMED", \
  "--add-opens", "jdk.management/com.sun.management.internal=ALL-UNNAMED", \
  "-jar", "hazelcast.jar"]
