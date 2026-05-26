FROM docker.io/library/maven:3.8.7-eclipse-temurin-11 AS builder

WORKDIR /build

COPY pom.xml .
COPY customize-rules.xml .
COPY docs-core/pom.xml ./docs-core/pom.xml
COPY docs-web-common/pom.xml ./docs-web-common/pom.xml
COPY docs-web/pom.xml ./docs-web/pom.xml

COPY docs-core ./docs-core
COPY docs-web-common ./docs-web-common
COPY docs-web ./docs-web

RUN mvn -B clean install -DskipTests

FROM docker.io/library/tomcat:10.0.27-jdk11-temurin

RUN rm -rf /usr/local/tomcat/webapps/*

COPY --from=builder /build/docs-web/target/*.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080

CMD ["catalina.sh", "run"]
