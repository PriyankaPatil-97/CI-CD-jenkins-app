# My Sample App

This is a simple Spring Boot application with a CI/CD pipeline.

## Run Locally
```bash
mvn clean package -DskipTests
java -jar target/my-sample-app-1.0.0.jar
```

Visit: http://localhost:9090/hello

## Docker
```bash
docker build -t my-sample-app .
docker run -p 9090:9090 my-sample-app
```
