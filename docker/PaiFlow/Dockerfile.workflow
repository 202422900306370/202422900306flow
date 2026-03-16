#多阶段构建Dockerfile，第一阶段使用Maven构建Java应用，第二阶段使用轻量级JRE运行应用
FROM docker.m.daocloud.io/library/maven:3.9.9-eclipse-temurin-21-noble AS build
WORKDIR /app

# Copy workflow source,将workflow-java模块的源代码复制到docker环境
COPY core-workflow-java /app/core-workflow-java
WORKDIR /app/core-workflow-java

# Build
RUN mvn clean package -DskipTests

# Runtime stage
FROM docker.m.daocloud.io/library/eclipse-temurin:21-jre-noble # 仅包含JRE运行环境，不包含JDK和Maven
WORKDIR /app # 运行阶段的工作目录，和构建阶段的/app无关

# Set timezone
RUN ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone

# Copy built jar
COPY --from=build /app/core-workflow-java/target/workflow-java.jar /app/workflow-java.jar

# Logs
RUN mkdir -p /app/logs

# Expose port，记录容器对外暴露的端口，workflow-java应用默认监听7880端口
EXPOSE 7880

# Health check
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
  CMD wget --quiet --tries=1 --spider http://localhost:7880/actuator/health || exit 1

# Entrypoint
ENTRYPOINT ["java", \
    "-XX:+UseContainerSupport", \
    "-XX:MaxRAMPercentage=75.0", \
    "-Djava.security.egd=file:/dev/./urandom", \
    "-Duser.timezone=Asia/Shanghai", \
    "-jar", \
    "/app/workflow-java.jar"]
