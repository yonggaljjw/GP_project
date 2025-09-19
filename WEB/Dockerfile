# ---------- Build Stage ----------
FROM maven:3.9.6-eclipse-temurin-21 AS builder
WORKDIR /app
COPY pom.xml .
RUN mvn -q -e -DskipTests dependency:go-offline
COPY src ./src
RUN mvn -q -DskipTests clean package

# ---------- Run Stage ----------
FROM eclipse-temurin:21-jre
WORKDIR /app
# 보안: 비루트 유저 사용
RUN useradd -r -u 1001 spring && chown -R spring:spring /app
USER spring

COPY --from=builder /app/target/*.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java","-jar","app.jar"]