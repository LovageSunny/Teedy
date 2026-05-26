FROM maven:3.8.7-eclipse-temurin-11 AS builder

WORKDIR /build

COPY pom.xml .
COPY docs-core ./docs-core
COPY docs-web-common ./docs-web-common
COPY docs-web ./docs-web

RUN mvn clean install -DskipTests

FROM tomcat:9.0-jre11-temurin

RUN rm -rf /usr/local/tomcat/webapps/*

COPY --from=builder /build/docs-web/target/*.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080

CMD ["catalina.sh", "run"]
