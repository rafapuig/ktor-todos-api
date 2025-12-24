#FROM gradle:8-jdk17 AS build
#WORKDIR /app
#COPY . .
#RUN gradle buildFatJar --no-daemon

#FROM eclipse-temurin:17-jre
#WORKDIR /app
#COPY --from=build /app/build/libs/*-all.jar app.jar
#EXPOSE 8080
#CMD ["java", "-jar", "app.jar"]

# Build stage
#FROM eclipse-temurin:17-jdk AS builder
#WORKDIR /app

# ======= Stage 1: Build =======
FROM eclipse-temurin:17-jdk AS builder
WORKDIR /app

# Copiamos todo el proyecto
COPY . .

# Construimos el JAR (sin tests para acelerar)
RUN ./gradlew clean build -x test

# ======= Stage 2: Run =======
FROM eclipse-temurin:17-jre
WORKDIR /app

# Copiamos solo el JAR generado
COPY --from=builder /app/build/libs/*.jar app.jar

# Puerto que Railway inyecta
ENV PORT=8080
EXPOSE 8080

# Ejecutar la aplicación
CMD ["java", "-jar", "app.jar"]

