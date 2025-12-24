# --- FASE 1: CONSTRUCCIÓN (Build Stage) ---
# Usamos una imagen de Gradle con JDK 17. Esta imagen CONTIENE el compilador y Gradle.
FROM gradle:8.5.0-jdk17 AS build

# Establecemos el directorio de trabajo dentro del contenedor
WORKDIR /home/gradle/src

# Copiamos los ficheros de configuración de Gradle para que descargue las dependencias
COPY build.gradle.kts settings.gradle.kts ./
# Copiamos el código fuente de nuestra API
COPY src ./src

# Comando para construir la aplicación y empaquetarla en un 'fat JAR'.
# El plugin 'shadowJar' crea un JAR que incluye todas las dependencias necesarias.
# Asegúrate de tener este plugin en tu `build.gradle.kts`.
RUN gradle shadowJar --no-daemon

# --- FASE 2: EJECUCIÓN (Runtime Stage) ---
# Usamos una imagen de Java mucho más ligera, ya que solo necesitamos ejecutar el JAR.
FROM openjdk:17-jdk-slim

# Exponemos el puerto 8080. Railway lo gestionará automáticamente.
EXPOSE 8080

# Copiamos SOLO el JAR compilado desde la fase de construcción anterior.
# Esta es la magia del multi-stage: el resultado de la fase 'build' se pasa a esta fase.
COPY --from=build /home/gradle/src/build/libs/*.jar /app/app.jar

# Establecemos el directorio de trabajo final
WORKDIR /app

# El comando que Railway ejecutará para iniciar tu servidor Ktor
ENTRYPOINT ["java", "-jar", "app.jar"]





