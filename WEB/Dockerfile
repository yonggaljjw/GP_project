# ---------- Build Stage ----------
# Maven + JDK 21 환경에서 빌드 (WAR 파일 생성)
FROM maven:3.9.6-eclipse-temurin-21 AS builder

# 컨테이너 내부 작업 디렉토리 설정
WORKDIR /app

# pom.xml만 먼저 복사 (의존성 캐시 최적화 목적)
COPY pom.xml .

# 의존성 미리 다운로드 (캐시 활용 → 이후 빌드 속도 개선)
RUN mvn -q -DskipTests dependency:go-offline

# 실제 소스 코드 복사
COPY src ./src

# 테스트 생략하고 빌드 → target/*.war 생성됨
RUN mvn -q -DskipTests clean package


# ---------- Run Stage ----------
# Tomcat 9 + JDK 21 이미지를 실행 환경으로 사용
FROM tomcat:10.1-jdk21-temurin

# Tomcat 기본 작업 디렉토리
WORKDIR /usr/local/tomcat

# Tomcat이 기본으로 제공하는 webapps 예제 제거 (ROOT, docs, examples 등)
RUN rm -rf webapps/*

# Build Stage에서 만든 WAR 파일을 Tomcat의 ROOT.war로 복사
# → 컨테이너 실행 시 http://localhost:포트/ 에서 바로 접근 가능
COPY --from=builder /app/target/*.war webapps/ROOT.war

# # 컨테이너 내부에서 노출할 포트 (Tomcat 기본 포트 8080)
EXPOSE 8080

# 컨테이너 시작 시 톰캣 실행
CMD ["catalina.sh", "run"]
