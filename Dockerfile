# ==============================
# Build Stage : 이미지 생성 단계
# ==============================
# 1. 생성하려는 이미지의 베이스이미지를 선택.
FROM gradle:7.6.1-jdk17 AS builder

# 컨테이너상에서 작업할 경로: 경로 설정후, 모든 명령문의 기준경로가 된다.
WORKDIR /home/gradle/project

# COPY [소스코드파일] -> [이미지경로에 복사]
# gradlew 파일과 gradle 디렉토리 복사
COPY gradlew .
COPY gradle gradle

# 프로젝트 메타데이터 파일 복사
COPY build.gradle settings.gradle ./

# 필요한 경우 기타 설정 파일 복사 (예: .gitignore 등)
# COPY other-files .

# gradlew 실행 권한 부여
RUN chmod +x ./gradlew

# 소스 코드 복사
COPY src src

# Gradle 빌드 (테스트 제외) - JAR 파일 생성
RUN ./gradlew build --no-daemon -x test

# ==============================
# Runtime Stage : 컨테이너 생성 단계
# ==============================
# 2. 실행 스테이지
FROM eclipse-temurin:17-jre-alpine

# 작업 디렉토리 설정
WORKDIR /app

# 빌드 스테이지에서 생성된 JAR 파일 복사
COPY --from=builder /home/gradle/project/build/libs/*.jar app.jar

# 애플리케이션 포트 노출
EXPOSE 8080

# 애플리케이션 실행
ENTRYPOINT ["java", "-jar", "app.jar"]
