FROM eclipse-temurin:21-jre-alpine
LABEL maintainer="thebuilders"

WORKDIR /app

COPY target/*.jar app.jar

EXPOSE 8761

ENTRYPOINT ["java", "-jar", "app.jar"]
