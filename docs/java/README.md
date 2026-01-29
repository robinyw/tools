# Java 项目安装部署指南

## 环境要求

- JDK >= 8 (推荐 JDK 11 或 17)
- Maven >= 3.6 或 Gradle >= 6.0

## 安装步骤

### 1. 安装 JDK

#### Windows
从 [Oracle JDK](https://www.oracle.com/java/technologies/downloads/) 或 [OpenJDK](https://adoptium.net/) 下载并安装。

配置环境变量：
```cmd
JAVA_HOME=C:\Program Files\Java\jdk-17
PATH=%JAVA_HOME%\bin;%PATH%
```

#### macOS
```bash
# 使用 Homebrew
brew install openjdk@17

# 或下载安装包
https://adoptium.net/

# 设置 JAVA_HOME
echo 'export JAVA_HOME=/usr/local/opt/openjdk@17' >> ~/.zshrc
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> ~/.zshrc
source ~/.zshrc
```

#### Linux (Ubuntu/Debian)
```bash
# 安装 OpenJDK
sudo apt update
sudo apt install openjdk-17-jdk

# 验证安装
java -version
javac -version

# 设置 JAVA_HOME
echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64' >> ~/.bashrc
echo 'export PATH=$JAVA_HOME/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
```

### 2. 安装构建工具

#### Maven

```bash
# Linux/macOS
wget https://dlcdn.apache.org/maven/maven-3/3.9.5/binaries/apache-maven-3.9.5-bin.tar.gz
tar -xvf apache-maven-3.9.5-bin.tar.gz
sudo mv apache-maven-3.9.5 /opt/maven

# 配置环境变量
echo 'export M2_HOME=/opt/maven' >> ~/.bashrc
echo 'export PATH=$M2_HOME/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

# 使用 Homebrew (macOS)
brew install maven

# 验证
mvn -version
```

#### Gradle

```bash
# 使用 SDKMAN
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
sdk install gradle

# 使用 Homebrew (macOS)
brew install gradle

# 验证
gradle -version
```

### 3. 初始化项目

#### Maven 项目

```bash
# 创建新项目
mvn archetype:generate \
  -DgroupId=com.example \
  -DartifactId=my-app \
  -DarchetypeArtifactId=maven-archetype-quickstart \
  -DinteractiveMode=false

cd my-app

# 或克隆现有项目
git clone <repository-url>
cd <project-directory>
```

#### Gradle 项目

```bash
# 创建新项目
mkdir my-app && cd my-app
gradle init --type java-application

# 或克隆现有项目
git clone <repository-url>
cd <project-directory>
```

### 4. 构建项目

#### Maven

```bash
# 编译项目
mvn compile

# 运行测试
mvn test

# 打包项目
mvn package

# 清理并重新构建
mvn clean install

# 跳过测试
mvn install -DskipTests
```

#### Gradle

```bash
# 编译项目
./gradlew build

# 运行测试
./gradlew test

# 清理并重新构建
./gradlew clean build

# 跳过测试
./gradlew build -x test
```

## 开发环境配置

### IDE 配置

#### IntelliJ IDEA
1. 打开项目：File → Open → 选择项目目录
2. 等待 IDE 自动导入依赖
3. 配置 JDK：File → Project Structure → Project SDK

#### Eclipse
1. 导入 Maven 项目：File → Import → Maven → Existing Maven Projects
2. 导入 Gradle 项目：File → Import → Gradle → Existing Gradle Project

#### VS Code
```bash
# 安装 Java 扩展包
code --install-extension vscjava.vscode-java-pack
```

### 应用配置

#### Spring Boot 项目

`application.properties`:
```properties
server.port=8080
spring.application.name=my-app

# 数据库配置
spring.datasource.url=jdbc:mysql://localhost:3306/mydb
spring.datasource.username=root
spring.datasource.password=password
spring.jpa.hibernate.ddl-auto=update

# 日志配置
logging.level.root=INFO
logging.level.com.example=DEBUG
```

或使用 `application.yml`:
```yaml
server:
  port: 8080

spring:
  application:
    name: my-app
  datasource:
    url: jdbc:mysql://localhost:3306/mydb
    username: root
    password: password
  jpa:
    hibernate:
      ddl-auto: update

logging:
  level:
    root: INFO
    com.example: DEBUG
```

### 运行开发服务器

#### Spring Boot

```bash
# 使用 Maven
mvn spring-boot:run

# 使用 Gradle
./gradlew bootRun

# 直接运行 jar
java -jar target/my-app-1.0.0.jar
```

#### 普通 Java 应用

```bash
# 编译
javac -d bin src/com/example/Main.java

# 运行
java -cp bin com.example.Main

# 或使用 Maven
mvn exec:java -Dexec.mainClass="com.example.Main"
```

## 依赖管理

### Maven

`pom.xml`:
```xml
<dependencies>
    <!-- Spring Boot -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
        <version>3.1.5</version>
    </dependency>
    
    <!-- MySQL -->
    <dependency>
        <groupId>com.mysql</groupId>
        <artifactId>mysql-connector-j</artifactId>
        <version>8.2.0</version>
    </dependency>
    
    <!-- Lombok -->
    <dependency>
        <groupId>org.projectlombok</groupId>
        <artifactId>lombok</artifactId>
        <version>1.18.30</version>
        <scope>provided</scope>
    </dependency>
    
    <!-- 测试依赖 -->
    <dependency>
        <groupId>org.junit.jupiter</groupId>
        <artifactId>junit-jupiter</artifactId>
        <version>5.10.0</version>
        <scope>test</scope>
    </dependency>
</dependencies>
```

### Gradle

`build.gradle`:
```groovy
dependencies {
    // Spring Boot
    implementation 'org.springframework.boot:spring-boot-starter-web:3.1.5'
    
    // MySQL
    implementation 'com.mysql:mysql-connector-j:8.2.0'
    
    // Lombok
    compileOnly 'org.projectlombok:lombok:1.18.30'
    annotationProcessor 'org.projectlombok:lombok:1.18.30'
    
    // 测试依赖
    testImplementation 'org.junit.jupiter:junit-jupiter:5.10.0'
}
```

## 测试

### JUnit 5

```java
import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.*;

class CalculatorTest {
    
    @Test
    void testAddition() {
        Calculator calc = new Calculator();
        assertEquals(5, calc.add(2, 3));
    }
}
```

### 运行测试

```bash
# Maven
mvn test

# Gradle
./gradlew test

# 生成测试报告
mvn surefire-report:report
./gradlew test jacocoTestReport
```

## 部署到生产环境

### 1. 构建可执行 JAR

#### Maven

```bash
# 使用 maven-shade-plugin 或 spring-boot-maven-plugin
mvn clean package

# 输出位置
target/my-app-1.0.0.jar
```

#### Gradle

```bash
# 使用 gradle-shadow-plugin 或 spring-boot-gradle-plugin
./gradlew bootJar

# 输出位置
build/libs/my-app-1.0.0.jar
```

### 2. 运行应用

```bash
# 基本运行
java -jar my-app.jar

# 指定配置文件
java -jar my-app.jar --spring.profiles.active=prod

# 设置 JVM 参数
java -Xms512m -Xmx2g -jar my-app.jar

# 后台运行
nohup java -jar my-app.jar > app.log 2>&1 &
```

### 3. 使用 Systemd 管理服务

创建服务文件 `/etc/systemd/system/myapp.service`:

```ini
[Unit]
Description=My Java Application
After=syslog.target network.target

[Service]
Type=simple
User=appuser
WorkingDirectory=/opt/myapp
ExecStart=/usr/bin/java -jar /opt/myapp/my-app.jar
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

启动服务：

```bash
sudo systemctl daemon-reload
sudo systemctl start myapp
sudo systemctl enable myapp
sudo systemctl status myapp
```

### 4. 使用 Docker 部署

创建 `Dockerfile`:

```dockerfile
FROM openjdk:17-jdk-slim

WORKDIR /app

COPY target/my-app-1.0.0.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
```

多阶段构建：

```dockerfile
# 构建阶段
FROM maven:3.9-openjdk-17 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

# 运行阶段
FROM openjdk:17-jdk-slim
WORKDIR /app
COPY --from=build /app/target/my-app-1.0.0.jar app.jar
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
```

构建和运行：

```bash
# 构建镜像
docker build -t my-app:latest .

# 运行容器
docker run -d -p 8080:8080 --name my-app my-app:latest

# 查看日志
docker logs -f my-app
```

### 5. Kubernetes 部署

创建 `deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app
spec:
  replicas: 3
  selector:
    matchLabels:
      app: my-app
  template:
    metadata:
      labels:
        app: my-app
    spec:
      containers:
      - name: my-app
        image: my-app:latest
        ports:
        - containerPort: 8080
        env:
        - name: SPRING_PROFILES_ACTIVE
          value: "prod"
---
apiVersion: v1
kind: Service
metadata:
  name: my-app-service
spec:
  selector:
    app: my-app
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
  type: LoadBalancer
```

部署：

```bash
kubectl apply -f deployment.yaml
kubectl get pods
kubectl get services
```

## 监控和日志

### 日志配置

`logback-spring.xml`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<configuration>
    <appender name="STDOUT" class="ch.qos.logback.core.ConsoleAppender">
        <encoder>
            <pattern>%d{yyyy-MM-dd HH:mm:ss} - %msg%n</pattern>
        </encoder>
    </appender>
    
    <appender name="FILE" class="ch.qos.logback.core.rolling.RollingFileAppender">
        <file>logs/application.log</file>
        <rollingPolicy class="ch.qos.logback.core.rolling.TimeBasedRollingPolicy">
            <fileNamePattern>logs/application-%d{yyyy-MM-dd}.log</fileNamePattern>
            <maxHistory>30</maxHistory>
        </rollingPolicy>
        <encoder>
            <pattern>%d{yyyy-MM-dd HH:mm:ss} [%thread] %-5level %logger{36} - %msg%n</pattern>
        </encoder>
    </appender>
    
    <root level="INFO">
        <appender-ref ref="STDOUT"/>
        <appender-ref ref="FILE"/>
    </root>
</configuration>
```

### Spring Boot Actuator

添加依赖：

```xml
<dependency>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-actuator</artifactId>
</dependency>
```

配置：

```properties
management.endpoints.web.exposure.include=health,info,metrics
management.endpoint.health.show-details=always
```

访问监控端点：
- http://localhost:8080/actuator/health
- http://localhost:8080/actuator/metrics

## 常见问题

### 内存溢出

```bash
# 增加堆内存
java -Xms1g -Xmx4g -jar app.jar

# 启用 GC 日志
java -Xlog:gc*:file=gc.log -jar app.jar
```

### 端口被占用

```bash
# 查找占用端口的进程
lsof -i :8080
netstat -tulpn | grep 8080

# 结束进程
kill -9 <PID>
```

### 依赖冲突

```bash
# 查看依赖树
mvn dependency:tree
./gradlew dependencies

# 排除冲突依赖
# Maven
<dependency>
    <groupId>com.example</groupId>
    <artifactId>some-lib</artifactId>
    <exclusions>
        <exclusion>
            <groupId>conflicting-group</groupId>
            <artifactId>conflicting-artifact</artifactId>
        </exclusion>
    </exclusions>
</dependency>

# Gradle
implementation('com.example:some-lib') {
    exclude group: 'conflicting-group', module: 'conflicting-artifact'
}
```

## 最佳实践

1. 使用统一的 Java 版本（推荐 LTS 版本）
2. 使用依赖管理工具锁定版本
3. 配置持续集成/持续部署（CI/CD）
4. 使用配置文件管理不同环境
5. 实施日志记录和监控
6. 定期更新依赖以修复安全漏洞
7. 使用容器化简化部署
8. 编写单元测试和集成测试

## 相关资源

- [Oracle Java 文档](https://docs.oracle.com/en/java/)
- [Spring Boot 文档](https://spring.io/projects/spring-boot)
- [Maven 文档](https://maven.apache.org/guides/)
- [Gradle 文档](https://docs.gradle.org/)
- [Docker 文档](https://docs.docker.com/)
