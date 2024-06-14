FROM openjdk:11-jre-slim
VOLUME /tmp
COPY target/microservicio.jar microservicio.jar
ENTRYPOINT ["java","-jar","/microservicio.jar"]
