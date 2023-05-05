FROM maven:3.6-alpine as DEPS

WORKDIR /opt/app
COPY microservice-kubernetes-demo-catalog/pom.xml microservice-kubernetes-demo-catalog/pom.xml
COPY microservice-kubernetes-demo-customer/pom.xml microservice-kubernetes-demo-customer/pom.xml
COPY microservice-kubernetes-demo-order/pom.xml microservice-kubernetes-demo-order/pom.xml

COPY pom.xml .
RUN mvn -B -e -C org.apache.maven.plugins:maven-dependency-plugin:3.1.2:go-offline

# if you have modules that depends each other, you may use -DexcludeArtifactIds as follows
# RUN mvn -B -e -C org.apache.maven.plugins:maven-dependency-plugin:3.1.2:go-offline -DexcludeArtifactIds=module1

# Copy the dependencies from the DEPS stage with the advantage
# of using docker layer caches. If something goes wrong from this
# line on, all dependencies from DEPS were already downloaded and
# stored in docker's layers.
FROM maven:3-eclipse-temurin-11 as BUILD
WORKDIR /opt/app
COPY --from=DEPS /root/.m2 /root/.m2
COPY --from=DEPS /opt/app/ /opt/app
COPY microservice-kubernetes-demo-catalog/src /opt/app/microservice-kubernetes-demo-catalog/src
COPY microservice-kubernetes-demo-customer/src /opt/app/microservice-kubernetes-demo-customer/src
COPY microservice-kubernetes-demo-order/src /opt/app/microservice-kubernetes-demo-order/src
RUN mvn -B -e clean install -DskipTests=true

FROM openjdk:11.0.2-jre-slim as CATALOG
COPY --from=BUILD /opt/app/microservice-kubernetes-demo-catalog/target/microservice-kubernetes-demo-catalog-0.0.1-SNAPSHOT.jar .
CMD /usr/bin/java -Xmx400m -Xms400m -jar microservice-kubernetes-demo-catalog-0.0.1-SNAPSHOT.jar
EXPOSE 8080

FROM openjdk:11.0.2-jre-slim as CUSTOMER
COPY --from=BUILD /opt/app/microservice-kubernetes-demo-customer/target/microservice-kubernetes-demo-customer-0.0.1-SNAPSHOT.jar .
CMD /usr/bin/java -Xmx400m -Xms400m -jar microservice-kubernetes-demo-customer-0.0.1-SNAPSHOT.jar
EXPOSE 8080

FROM openjdk:11.0.2-jre-slim as ORDER
COPY --from=BUILD /opt/app/microservice-kubernetes-demo-order/target/microservice-kubernetes-demo-order-0.0.1-SNAPSHOT.jar .
CMD /usr/bin/java -Xmx400m -Xms400m -jar microservice-kubernetes-demo-order-0.0.1-SNAPSHOT.jar
EXPOSE 8080
