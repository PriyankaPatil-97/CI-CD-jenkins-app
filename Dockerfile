FROM openjdk:17-jdk-slim
WORKDIR /app
COPY target/my-sample-app-1.0.0.jar app.jar
EXPOSE 9090
ENTRYPOINT ["java","-jar","/app/app.jar"]
