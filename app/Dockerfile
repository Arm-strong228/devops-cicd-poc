# --- Etape 1 : build de l'application avec Maven ---
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /build
COPY pom.xml .
COPY src ./src
RUN mvn -B clean package -DskipTests

# --- Etape 2 : image finale, legere, avec juste le JRE ---
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app
COPY --from=build /build/target/demo.jar app.jar

EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
