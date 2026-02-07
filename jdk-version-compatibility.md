# JDK 版本兼容性清单

本文档维护 JDK 各版本与主流构建工具和框架的稳定版本对应关系。

## 版本兼容性对照表

### JDK 8

| 工具/框架 | 推荐稳定版本 | 备注 |
|---------|------------|------|
| **Gradle** | 7.6.4 | 最后一个完整支持 JDK 8 的 7.x 版本 |
| **Maven** | 3.8.8 | Maven 3.6.3+ 均支持 JDK 8 |
| **Spring Framework** | 5.3.31 | Spring 5.x 系列最新版本 |
| **Spring Boot** | 2.7.18 | Spring Boot 2.x 系列最新版本 |

**注意事项：**
- JDK 8 虽然仍被广泛使用，但已不再是主流版本
- Spring Boot 2.x 将于 2023 年 11 月停止维护
- 建议新项目考虑使用 JDK 17 或更高版本

### JDK 17 (LTS)

| 工具/框架 | 推荐稳定版本 | 备注 |
|---------|------------|------|
| **Gradle** | 8.5 | 完整支持 JDK 17，推荐使用 8.x 系列 |
| **Maven** | 3.9.6 | Maven 3.8.1+ 均支持 JDK 17 |
| **Spring Framework** | 6.1.3 | Spring 6.x 系列稳定版本 |
| **Spring Boot** | 3.2.2 | Spring Boot 3.x 系列稳定版本，要求 JDK 17+ |

**注意事项：**
- JDK 17 是长期支持版本 (LTS)，推荐用于生产环境
- Spring Boot 3.x 最低要求 JDK 17
- 这是目前最推荐的 Java 生产环境版本

### JDK 21 (LTS)

| 工具/框架 | 推荐稳定版本 | 备注 |
|---------|------------|------|
| **Gradle** | 8.5+ | Gradle 8.4+ 完整支持 JDK 21 |
| **Maven** | 3.9.6 | Maven 3.9.0+ 支持 JDK 21 |
| **Spring Framework** | 6.1.3 | Spring 6.1+ 完整支持 JDK 21 |
| **Spring Boot** | 3.2.2 | Spring Boot 3.2+ 完整支持 JDK 21 |

**注意事项：**
- JDK 21 是最新的长期支持版本 (LTS)
- 包含虚拟线程、结构化并发等新特性
- 适合希望使用最新特性的项目

### JDK 25

| 工具/框架 | 推荐稳定版本 | 备注 |
|---------|------------|------|
| **Gradle** | 8.12+ | 需要 Gradle 8.10+ 以支持 JDK 25 |
| **Maven** | 3.9.6+ | Maven 3.9.x 系列支持 JDK 25 |
| **Spring Framework** | 6.2.0+ | Spring 6.2+ 支持 JDK 25 |
| **Spring Boot** | 3.4.0+ | Spring Boot 3.4+ 支持 JDK 25 |

**注意事项：**
- JDK 25 是非 LTS 版本，不建议用于生产环境
- 仅建议用于实验和测试新特性
- 生产环境推荐使用 LTS 版本（JDK 17 或 21）

## 版本选择建议

### 新项目推荐

1. **保守稳定**: JDK 17 + Spring Boot 3.2.x + Maven 3.9.x
2. **追求新特性**: JDK 21 + Spring Boot 3.2.x + Gradle 8.5+
3. **遗留项目**: JDK 8 + Spring Boot 2.7.x + Maven 3.8.x

### 升级路径

```
JDK 8 + Spring Boot 2.x
    ↓
JDK 17 + Spring Boot 3.x
    ↓
JDK 21 + Spring Boot 3.x
```

## 版本更新日志

| 更新日期 | 更新内容 |
|---------|---------|
| 2024-02 | 初始版本创建 |

## 参考资料

- [Gradle Compatibility Matrix](https://docs.gradle.org/current/userguide/compatibility.html)
- [Maven Compatibility](https://maven.apache.org/docs/history.html)
- [Spring Boot System Requirements](https://docs.spring.io/spring-boot/docs/current/reference/html/getting-started.html#getting-started.system-requirements)
- [Spring Framework Versions](https://github.com/spring-projects/spring-framework/wiki/Spring-Framework-Versions)
- [JDK Release Roadmap](https://www.oracle.com/java/technologies/java-se-support-roadmap.html)
