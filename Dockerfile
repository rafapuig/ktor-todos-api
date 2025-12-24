# --- FASE 1: CONSTRUCCIÓN (Build Stage) ---
# Usamos una imagen de Gradle con JDK 17. Esta imagen CONTIENE el compilador y Gradle.
# No hay cambios en esta fase, está correcta.
FROM gradle:8.5.0-jdk17 AS build

# Establecemos el directorio de trabajo dentro del contenedor
WORKDIR /home/gradle/src

# Copiamos los ficheros de configuración de Gradle para que descargue las dependencias
COPY build.gradle.kts settings.gradle.kts ./

# Copiamos el código fuente de nuestra API
COPY src ./src

# Comando para construir la aplicación y empaquetarla en un 'fat JAR'.
RUN gradle shadowJar --no-daemon

# --- FASE 2: EJECUCIÓN (Runtime Stage) ---
# Usamos una imagen de Java mucho más ligera y moderna.
#
# ----- ¡AQUÍ ESTÁ LA CORRECCIÓN! -----
#
# ANTES: FROM openjdk:17-jdk-slim
# AHORA:
FROM eclipse-temurin:17-jre-jammy

# Exponemos el puerto 8080. Railway lo gestionará automáticamente.
EXPOSE 8080

# Copiamos SOLO el JAR compilado desde la fase de construcción anterior.
COPY --from=build /home/gradle/src/build/libs/*.jar /app/app.jar

# Establecemos el directorio de trabajo final
WORKDIR /app

# El comando que Railway ejecutará para iniciar tu servidor Ktor
ENTRYPOINT ["java", "-jar", "app.jar"]




