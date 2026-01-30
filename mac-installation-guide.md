# Mac 开发环境安装指南

本文档提供在 macOS 上安装开发工具的详细指南，包括 npm、Python、Java、Maven 和 Gradle。对于 npm、Python 和 Java，我们将安装版本管理工具，以便轻松切换不同版本。特别针对 Mac M 芯片（Apple Silicon）提供了优化的配置方案。

## 目录
- [安装 Homebrew](#安装-homebrew)
- [安装 npm (使用 nvm)](#安装-npm-使用-nvm)
- [安装 Python (使用 pyenv)](#安装-python-使用-pyenv)
- [安装 Java](#安装-java)
- [安装 Zulu JDK (Mac M 芯片优化)](#安装-zulu-jdk-mac-m-芯片优化)
- [安装 Maven](#安装-maven)
- [安装 Gradle](#安装-gradle)

---

## 安装 Homebrew

Homebrew 是 macOS 的包管理器，我们将使用它来安装大部分工具。

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

安装完成后，验证安装：

```bash
brew --version
```

---

## 安装 npm (使用 nvm)

nvm (Node Version Manager) 允许您在同一台机器上安装和管理多个 Node.js 版本。

### 1. 安装 nvm

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
```

### 2. 配置环境变量

安装完成后，将以下内容添加到您的 shell 配置文件（`~/.zshrc` 或 `~/.bash_profile`）：

```bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
```

重新加载配置文件：

```bash
source ~/.zshrc  # 如果使用 zsh
# 或
source ~/.bash_profile  # 如果使用 bash
```

### 3. 验证 nvm 安装

```bash
nvm --version
```

### 4. 安装 Node.js (包含 npm)

安装最新的 LTS 版本：

```bash
nvm install --lts
```

安装特定版本：

```bash
nvm install 18.17.0
nvm install 20.10.0
```

### 5. 切换 Node.js 版本

查看已安装的版本：

```bash
nvm list
```

切换到特定版本：

```bash
nvm use 18.17.0
```

设置默认版本：

```bash
nvm alias default 20.10.0
```

### 6. 验证 Node.js 和 npm 安装

```bash
node --version
npm --version
```

### 常用 nvm 命令

| 命令 | 说明 |
|------|------|
| `nvm install <version>` | 安装指定版本的 Node.js |
| `nvm use <version>` | 切换到指定版本 |
| `nvm list` | 列出已安装的所有版本 |
| `nvm list-remote` | 列出所有可用的远程版本 |
| `nvm current` | 显示当前使用的版本 |
| `nvm alias default <version>` | 设置默认版本 |
| `nvm uninstall <version>` | 卸载指定版本 |

---

## 安装 Python (使用 pyenv)

pyenv 允许您在同一台机器上安装和管理多个 Python 版本。

### 1. 安装 pyenv 和依赖项

使用 Homebrew 安装：

```bash
brew install pyenv
```

### 2. 配置环境变量

将以下内容添加到您的 shell 配置文件（`~/.zshrc` 或 `~/.bash_profile`）：

对于 **zsh**（macOS 默认 shell）：

```bash
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
```

对于 **bash**：

```bash
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
```

重新加载配置文件：

```bash
source ~/.zshrc  # 如果使用 zsh
# 或
source ~/.bash_profile  # 如果使用 bash
```

### 3. 验证 pyenv 安装

```bash
pyenv --version
```

### 4. 安装 Python 版本

查看可用的 Python 版本：

```bash
pyenv install --list
```

安装特定版本：

```bash
pyenv install 3.11.7
pyenv install 3.12.1
```

### 5. 切换 Python 版本

查看已安装的版本：

```bash
pyenv versions
```

设置全局 Python 版本：

```bash
pyenv global 3.12.1
```

为当前目录设置 Python 版本：

```bash
pyenv local 3.11.7
```

为当前 shell 会话设置 Python 版本：

```bash
pyenv shell 3.12.1
```

### 6. 验证 Python 安装

```bash
python --version
python3 --version
```

### 常用 pyenv 命令

| 命令 | 说明 |
|------|------|
| `pyenv install <version>` | 安装指定版本的 Python |
| `pyenv versions` | 列出已安装的所有版本 |
| `pyenv global <version>` | 设置全局 Python 版本 |
| `pyenv local <version>` | 为当前目录设置 Python 版本 |
| `pyenv shell <version>` | 为当前 shell 会话设置 Python 版本 |
| `pyenv uninstall <version>` | 卸载指定版本 |
| `pyenv which python` | 显示当前 Python 可执行文件的路径 |

---

## 安装 Java

在 macOS 上安装 Java 有多种方法，我们推荐使用 Homebrew。

### 方法 1: 使用 Homebrew 安装 (推荐)

#### 安装最新版本的 OpenJDK

```bash
brew install openjdk
```

#### 设置环境变量

创建符号链接以便系统能找到 Java（根据您的 Mac 芯片类型选择）：

**对于 Apple Silicon (M1/M2/M3) Mac：**

```bash
sudo ln -sfn /opt/homebrew/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk
```

**对于 Intel Mac：**

```bash
sudo ln -sfn /usr/local/opt/openjdk/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk.jdk
```

将以下内容添加到您的 shell 配置文件（`~/.zshrc` 或 `~/.bash_profile`）：

```bash
export JAVA_HOME=$(/usr/libexec/java_home)
export PATH="$JAVA_HOME/bin:$PATH"
```

重新加载配置文件：

```bash
source ~/.zshrc  # 如果使用 zsh
# 或
source ~/.bash_profile  # 如果使用 bash
```

#### 安装特定版本的 Java

```bash
# Java 11
brew install openjdk@11

# Java 17
brew install openjdk@17
```

为特定版本创建符号链接：

**对于 Apple Silicon (M1/M2/M3) Mac：**

```bash
# Java 11
sudo ln -sfn /opt/homebrew/opt/openjdk@11/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-11.jdk

# Java 17
sudo ln -sfn /opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-17.jdk
```

**对于 Intel Mac：**

```bash
# Java 11
sudo ln -sfn /usr/local/opt/openjdk@11/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-11.jdk

# Java 17
sudo ln -sfn /usr/local/opt/openjdk@17/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-17.jdk
```

### 方法 2: 使用 jenv 管理 Java 版本 (可选)

如果您需要频繁切换 Java 版本，可以使用 jenv：

#### 安装 jenv

```bash
brew install jenv
```

#### 配置 jenv

将以下内容添加到您的 shell 配置文件：

```bash
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"
```

重新加载配置文件：

```bash
source ~/.zshrc  # 如果使用 zsh
```

#### 添加已安装的 Java 版本到 jenv

```bash
jenv add /Library/Java/JavaVirtualMachines/openjdk.jdk/Contents/Home
jenv add /Library/Java/JavaVirtualMachines/openjdk-11.jdk/Contents/Home
jenv add /Library/Java/JavaVirtualMachines/openjdk-17.jdk/Contents/Home
```

#### 切换 Java 版本

```bash
# 列出可用版本
jenv versions

# 设置全局版本（使用 jenv versions 中显示的完整版本号）
jenv global 17.0.2

# 为当前目录设置版本
jenv local 11.0.18
```

**注意**：使用 `jenv global` 或 `jenv local` 时，请使用 `jenv versions` 命令输出中显示的完整版本号。

### 方法 3: 下载 Oracle JDK (替代方案)

1. 访问 [Oracle JDK 下载页面](https://www.oracle.com/java/technologies/downloads/)
2. 下载适用于 macOS 的 .dmg 文件
3. 运行安装程序并按照提示操作

### 验证 Java 安装

```bash
java -version
javac -version
echo $JAVA_HOME
```

### 查看所有已安装的 Java 版本

```bash
/usr/libexec/java_home -V
```

### 切换 Java 版本（不使用 jenv）

临时切换（仅对当前 shell 会话有效）：

```bash
export JAVA_HOME=$(/usr/libexec/java_home -v 11)
```

---

## 验证所有安装

运行以下命令以验证所有工具都已正确安装：

```bash
# Node.js 和 npm
node --version
npm --version
nvm --version

# Python
python --version
pyenv --version

# Java
java -version
echo $JAVA_HOME

# jenv (如果安装了 jenv)
jenv versions

# Maven
mvn -version

# Gradle
gradle -version
```

---

## 故障排除

### nvm 命令未找到

确保您已将 nvm 初始化脚本添加到 shell 配置文件并重新加载了配置。

### pyenv 命令未找到

确保 Homebrew 安装成功，并且已将 pyenv 路径添加到 PATH 环境变量中。

### Java 未找到

确保已创建符号链接并设置了 JAVA_HOME 环境变量。

### Homebrew 安装失败

检查您的网络连接，或尝试使用国内镜像源。

---

## 总结

现在您已经在 macOS 上成功安装了：
- **npm** 和 **nvm**（Node.js 版本管理器）
- **Python** 和 **pyenv**（Python 版本管理器）
- **Java**（可选使用 jenv 进行版本管理）
- **Zulu JDK**（针对 Mac M 芯片优化的 OpenJDK，支持多版本管理）
- **Maven**（配置了镜像仓库以加速依赖下载）
- **Gradle**（配置了镜像仓库和性能优化）

这些工具将帮助您轻松管理和切换不同版本，以满足不同项目的需求。

### Mac M 芯片用户特别提示

如果您使用的是 Apple Silicon (M1/M2/M3) Mac：

1. **优先使用 Zulu JDK**: 它针对 ARM64 架构进行了优化，性能优于其他 JDK 发行版
2. **使用 jenv 管理多版本**: 可以轻松在不同项目间切换 Java 版本
3. **配置国内镜像**: Maven 和 Gradle 配置了阿里云等镜像，可以显著提升依赖下载速度
4. **启用并行构建**: M 系列芯片的多核心优势可以通过并行构建充分发挥
5. **检查架构**: 使用 `java -version` 确认安装的是 ARM64 版本，而不是 x86_64 版本

---

## 安装 Zulu JDK (Mac M 芯片优化)

Zulu JDK 是由 Azul Systems 提供的 OpenJDK 构建版本，专门针对 Apple Silicon (M1/M2/M3) 进行了优化，提供更好的性能和兼容性。

### 为什么选择 Zulu JDK？

- ✅ 原生支持 Apple Silicon (ARM64 架构)
- ✅ 更好的性能和能效
- ✅ 经过全面测试和认证
- ✅ 免费且商业友好
- ✅ 提供长期支持 (LTS) 版本

### 方法 1: 使用 Homebrew 安装 Zulu JDK (推荐)

#### 1. 添加 Zulu 仓库

```bash
brew tap homebrew/cask-versions
```

#### 2. 安装 Zulu JDK

安装最新的 LTS 版本 (Java 21)：

```bash
brew install --cask zulu21
```

安装其他版本：

```bash
# Java 17 LTS
brew install --cask zulu17

# Java 11 LTS
brew install --cask zulu11

# Java 8 LTS
brew install --cask zulu8
```

#### 3. 验证安装

```bash
java -version
```

您应该看到类似以下的输出：

```
openjdk version "21.0.1" 2023-10-17 LTS
OpenJDK Runtime Environment Zulu21.30+15-CA (build 21.0.1+12-LTS)
OpenJDK 64-Bit Server VM Zulu21.30+15-CA (build 21.0.1+12-LTS, mixed mode, sharing)
```

### 方法 2: 使用 jenv 管理多个 Zulu JDK 版本

如果您需要在同一台机器上使用多个 Java 版本，jenv 是最佳选择。

#### 1. 安装 jenv

```bash
brew install jenv
```

#### 2. 配置 jenv

将以下内容添加到您的 shell 配置文件（`~/.zshrc` 或 `~/.bash_profile`）：

```bash
# jenv 配置
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"
```

重新加载配置文件：

```bash
source ~/.zshrc  # 如果使用 zsh
```

启用 jenv 插件（这些是一次性命令，在终端中运行）：

```bash
jenv enable-plugin export
jenv enable-plugin maven
jenv enable-plugin gradle
```

#### 3. 安装多个 Zulu JDK 版本

```bash
# 安装多个版本
brew install --cask zulu8
brew install --cask zulu11
brew install --cask zulu17
brew install --cask zulu21
```

#### 4. 将 Zulu JDK 添加到 jenv

查找 Zulu JDK 的安装路径（**Apple Silicon Mac**）：

```bash
# 列出所有已安装的 Java 版本
/usr/libexec/java_home -V
```

输出示例：

```
21.0.1 (arm64) "Azul Systems, Inc." - "Zulu 21.30.15" /Library/Java/JavaVirtualMachines/zulu-21.jdk/Contents/Home
17.0.9 (arm64) "Azul Systems, Inc." - "Zulu 17.48.15" /Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home
11.0.21 (arm64) "Azul Systems, Inc." - "Zulu 11.68.17" /Library/Java/JavaVirtualMachines/zulu-11.jdk/Contents/Home
1.8.0_392 (arm64) "Azul Systems, Inc." - "Zulu 8.74.0.17" /Library/Java/JavaVirtualMachines/zulu-8.jdk/Contents/Home
```

将这些版本添加到 jenv：

```bash
jenv add /Library/Java/JavaVirtualMachines/zulu-21.jdk/Contents/Home
jenv add /Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home
jenv add /Library/Java/JavaVirtualMachines/zulu-11.jdk/Contents/Home
jenv add /Library/Java/JavaVirtualMachines/zulu-8.jdk/Contents/Home
```

#### 5. 管理 Java 版本

查看所有已添加的版本：

```bash
jenv versions
```

设置全局默认版本：

```bash
# 推荐使用完整版本号确保精确匹配
jenv global 17.0.9

# 也可以使用短版本号，jenv 会匹配最新的对应版本
jenv global 17.0
```

为当前项目目录设置版本：

```bash
cd /path/to/your/project
# 可以使用短版本号，jenv 会匹配最新的 11.0.x 版本
jenv local 11.0
```

这将在项目目录中创建一个 `.java-version` 文件，当您进入该目录时，jenv 会自动切换到指定的 Java 版本。

为当前 shell 会话设置版本：

```bash
jenv shell 21.0
```

#### 6. 验证当前 Java 版本

```bash
java -version
echo $JAVA_HOME
```

### Mac M 芯片特定说明

**Apple Silicon (M1/M2/M3) 重要提示：**

1. **架构确认**: 确保您安装的是 ARM64 版本的 Zulu JDK，而不是 x86_64 版本
   ```bash
   java -version
   # 应该显示 "arm64" 或 "aarch64"
   ```

2. **性能优化**: Zulu JDK 的 ARM64 版本针对 Apple Silicon 进行了优化，性能显著优于 Rosetta 2 转译的 x86 版本

3. **Homebrew 路径**: 在 Apple Silicon Mac 上，Homebrew 将软件安装在 `/opt/homebrew` 而不是 `/usr/local`

4. **系统 JDK 路径**: Zulu JDK 会自动安装到 `/Library/Java/JavaVirtualMachines/`，这是 macOS 的标准 JDK 位置

### 常用 jenv 命令

| 命令 | 说明 |
|------|------|
| `jenv versions` | 列出所有已添加的 Java 版本 |
| `jenv global <version>` | 设置全局默认版本 |
| `jenv local <version>` | 为当前目录设置版本（创建 .java-version 文件）|
| `jenv shell <version>` | 为当前 shell 会话设置版本 |
| `jenv add <path>` | 添加 Java 安装到 jenv |
| `jenv remove <version>` | 从 jenv 中移除版本 |
| `jenv which java` | 显示当前使用的 java 可执行文件路径 |
| `jenv enable-plugin <plugin>` | 启用 jenv 插件 |

### 故障排除

#### JAVA_HOME 未设置

如果 `echo $JAVA_HOME` 没有输出，确保您已启用 jenv 的 export 插件：

```bash
jenv enable-plugin export
```

然后重新加载配置文件：

```bash
source ~/.zshrc
```

#### Maven 或 Gradle 使用错误的 Java 版本

启用相应的插件：

```bash
jenv enable-plugin maven
jenv enable-plugin gradle
```

---

## 安装 Maven

Apache Maven 是一个项目管理和构建自动化工具，主要用于 Java 项目。

### 1. 使用 Homebrew 安装 Maven

```bash
brew install maven
```

### 2. 验证安装

```bash
mvn -version
```

输出应显示 Maven 版本、Java 版本和操作系统信息。

### 3. 配置 Maven

#### 查找 Maven 配置文件位置

Maven 的全局配置文件位于：

**Apple Silicon Mac:**
```bash
/opt/homebrew/opt/maven/libexec/conf/settings.xml
```

**Intel Mac:**
```bash
/usr/local/opt/maven/libexec/conf/settings.xml
```

#### 创建用户级配置文件（推荐）

创建用户级的 Maven 配置文件，这样不会影响全局配置：

```bash
mkdir -p ~/.m2
```

创建或编辑 `~/.m2/settings.xml`：

```bash
nano ~/.m2/settings.xml
```

### 4. 配置 Maven 仓库地址

#### 方案 1: 使用阿里云镜像（推荐，国内用户）

将以下内容添加到 `~/.m2/settings.xml`：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!-- 此配置适用于 Maven 3.x 及更高版本 -->
<settings xmlns="http://maven.apache.org/SETTINGS/1.2.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.2.0 
          http://maven.apache.org/xsd/settings-1.2.0.xsd">
  
  <!-- 本地仓库路径 -->
  <localRepository>${user.home}/.m2/repository</localRepository>
  
  <!-- 镜像配置 -->
  <mirrors>
    <!-- 阿里云公共仓库 -->
    <mirror>
      <id>aliyun-public</id>
      <name>Aliyun Public Repository</name>
      <url>https://maven.aliyun.com/repository/public</url>
      <mirrorOf>central</mirrorOf>
    </mirror>
    
    <!-- 阿里云 Spring 仓库 -->
    <mirror>
      <id>aliyun-spring</id>
      <name>Aliyun Spring Repository</name>
      <url>https://maven.aliyun.com/repository/spring</url>
      <mirrorOf>spring</mirrorOf>
    </mirror>
    
    <!-- 阿里云 Google 仓库 -->
    <mirror>
      <id>aliyun-google</id>
      <name>Aliyun Google Repository</name>
      <url>https://maven.aliyun.com/repository/google</url>
      <mirrorOf>google</mirrorOf>
    </mirror>
  </mirrors>
  
  <!-- 配置文件 -->
  <profiles>
    <profile>
      <id>aliyun</id>
      <repositories>
        <repository>
          <id>aliyun-central</id>
          <name>Aliyun Central</name>
          <url>https://maven.aliyun.com/repository/central</url>
          <releases>
            <enabled>true</enabled>
          </releases>
          <snapshots>
            <enabled>false</enabled>
          </snapshots>
        </repository>
        
        <repository>
          <id>aliyun-snapshots</id>
          <name>Aliyun Snapshots</name>
          <url>https://maven.aliyun.com/repository/snapshots</url>
          <releases>
            <enabled>false</enabled>
          </releases>
          <snapshots>
            <enabled>true</enabled>
          </snapshots>
        </repository>
      </repositories>
      
      <pluginRepositories>
        <pluginRepository>
          <id>aliyun-plugin</id>
          <name>Aliyun Plugin Repository</name>
          <url>https://maven.aliyun.com/repository/public</url>
          <releases>
            <enabled>true</enabled>
          </releases>
          <snapshots>
            <enabled>false</enabled>
          </snapshots>
        </pluginRepository>
      </pluginRepositories>
    </profile>
  </profiles>
  
  <!-- 激活配置文件 -->
  <activeProfiles>
    <activeProfile>aliyun</activeProfile>
  </activeProfiles>
</settings>
```

#### 方案 2: 使用腾讯云镜像（备选方案）

```xml
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.2.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.2.0 
          http://maven.apache.org/xsd/settings-1.2.0.xsd">
  
  <localRepository>${user.home}/.m2/repository</localRepository>
  
  <mirrors>
    <mirror>
      <id>tencent-cloud</id>
      <name>Tencent Cloud Repository</name>
      <url>https://mirrors.cloud.tencent.com/nexus/repository/maven-public/</url>
      <mirrorOf>central</mirrorOf>
    </mirror>
  </mirrors>
</settings>
```

#### 方案 3: 使用华为云镜像（备选方案）

```xml
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.2.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.2.0 
          http://maven.apache.org/xsd/settings-1.2.0.xsd">
  
  <localRepository>${user.home}/.m2/repository</localRepository>
  
  <mirrors>
    <mirror>
      <id>huawei-cloud</id>
      <name>Huawei Cloud Repository</name>
      <url>https://repo.huaweicloud.com/repository/maven/</url>
      <mirrorOf>central</mirrorOf>
    </mirror>
  </mirrors>
</settings>
```

### 5. 验证配置

创建一个简单的 Maven 项目来测试配置：

```bash
mvn archetype:generate -DgroupId=com.example -DartifactId=test-project -DarchetypeArtifactId=maven-archetype-quickstart -DinteractiveMode=false
cd test-project
mvn clean install
```

如果配置正确，Maven 将使用配置的镜像下载依赖。

### 6. 常用 Maven 命令

| 命令 | 说明 |
|------|------|
| `mvn clean` | 清理项目（删除 target 目录）|
| `mvn compile` | 编译项目 |
| `mvn test` | 运行测试 |
| `mvn package` | 打包项目 |
| `mvn install` | 安装到本地仓库 |
| `mvn deploy` | 部署到远程仓库 |
| `mvn clean install` | 清理并安装 |
| `mvn dependency:tree` | 查看依赖树 |
| `mvn versions:display-dependency-updates` | 检查依赖更新 |

### Mac M 芯片注意事项

- Maven 本身是 Java 应用程序，因此它会使用您配置的 Java 版本
- 如果使用 jenv，确保启用了 maven 插件：`jenv enable-plugin maven`
- 某些 Maven 插件可能需要特定的 Java 版本，可以在项目的 `pom.xml` 中指定

---

## 安装 Gradle

Gradle 是一个强大的构建自动化工具，广泛用于 Java、Android 和其他 JVM 语言项目。

### 1. 使用 Homebrew 安装 Gradle

```bash
brew install gradle
```

### 2. 验证安装

```bash
gradle -version
```

输出应显示 Gradle 版本、Kotlin 版本、Groovy 版本和 JVM 信息。

### 3. 配置 Gradle

#### 全局配置文件位置

创建 Gradle 全局配置目录：

```bash
mkdir -p ~/.gradle
```

#### 配置 Gradle 属性

创建或编辑 `~/.gradle/gradle.properties`：

```bash
nano ~/.gradle/gradle.properties
```

添加以下配置：

```properties
# Gradle 守护进程配置
org.gradle.daemon=true
org.gradle.parallel=true
org.gradle.configureondemand=true

# JVM 内存配置（根据您的 Mac 内存调整）
org.gradle.jvmargs=-Xmx4096m -XX:MaxMetaspaceSize=512m -XX:+HeapDumpOnOutOfMemoryError

# 启用 Gradle 构建缓存
org.gradle.caching=true

# 文件系统监控（提高增量构建性能）
org.gradle.vfs.watch=true

# 配置超时时间（毫秒）
systemProp.http.socketTimeout=60000
systemProp.http.connectionTimeout=60000
```

### 4. 配置 Gradle 仓库地址

#### 方案 1: 在 init.gradle 中全局配置镜像（推荐）

创建或编辑 `~/.gradle/init.gradle`：

```bash
nano ~/.gradle/init.gradle
```

添加以下内容（使用阿里云镜像）：

```groovy
allprojects {
    repositories {
        // 移除标准的公共仓库，替换为镜像
        // 注意：只移除 Maven Central、Apache Maven 和 JCenter 这些标准公共仓库
        // 您的项目中的自定义或私有仓库不会被影响
        all { ArtifactRepository repo ->
            if (repo instanceof MavenArtifactRepository) {
                def url = repo.url.toString()
                if (url.startsWith('https://repo1.maven.org/maven2') 
                    || url.startsWith('https://repo.maven.apache.org/maven2')
                    || url.startsWith('https://jcenter.bintray.com')) {
                    project.logger.lifecycle "Repository ${repo.url} replaced by Aliyun mirror."
                    remove repo
                }
            }
        }
        
        // 添加阿里云镜像
        maven { url 'https://maven.aliyun.com/repository/public' }
        maven { url 'https://maven.aliyun.com/repository/spring' }
        maven { url 'https://maven.aliyun.com/repository/google' }
        maven { url 'https://maven.aliyun.com/repository/gradle-plugin' }
        maven { url 'https://maven.aliyun.com/repository/spring-plugin' }
        
        // 保留原有的仓库作为后备
        mavenCentral()
        google()
    }
    
    buildscript {
        repositories {
            maven { url 'https://maven.aliyun.com/repository/public' }
            maven { url 'https://maven.aliyun.com/repository/gradle-plugin' }
            mavenCentral()
        }
    }
}
```

#### 方案 2: 使用腾讯云镜像

```groovy
allprojects {
    repositories {
        all { ArtifactRepository repo ->
            if (repo instanceof MavenArtifactRepository) {
                def url = repo.url.toString()
                if (url.startsWith('https://repo1.maven.org/maven2') 
                    || url.startsWith('https://repo.maven.apache.org/maven2')) {
                    project.logger.lifecycle "Repository ${repo.url} replaced by Tencent Cloud mirror."
                    remove repo
                }
            }
        }
        
        maven { url 'https://mirrors.cloud.tencent.com/nexus/repository/maven-public/' }
        mavenCentral()
        google()
    }
}
```

#### 方案 3: 在项目的 build.gradle 中配置

如果您只想为特定项目配置镜像，可以在项目的 `build.gradle` 或 `build.gradle.kts` 中添加：

**Groovy DSL (build.gradle):**

```groovy
repositories {
    maven { url 'https://maven.aliyun.com/repository/public' }
    maven { url 'https://maven.aliyun.com/repository/spring' }
    maven { url 'https://maven.aliyun.com/repository/google' }
    mavenCentral()
    google()
}
```

**Kotlin DSL (build.gradle.kts):**

```kotlin
repositories {
    maven("https://maven.aliyun.com/repository/public")
    maven("https://maven.aliyun.com/repository/spring")
    maven("https://maven.aliyun.com/repository/google")
    mavenCentral()
    google()
}
```

### 5. Gradle Wrapper 配置

对于使用 Gradle Wrapper 的项目，可以配置 Wrapper 下载地址。

编辑项目中的 `gradle/wrapper/gradle-wrapper.properties`：

```properties
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
# 使用腾讯云镜像下载 Gradle 发行版
# 将下面的 X.X 替换为您需要的 Gradle 版本（例如 8.5, 8.6, 8.10 等）
distributionUrl=https\://mirrors.cloud.tencent.com/gradle/gradle-X.X-bin.zip
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
```

### 6. 验证配置

创建一个简单的 Gradle 项目来测试配置：

```bash
mkdir gradle-test
cd gradle-test
gradle init --type basic --dsl groovy
gradle build
```

### 7. 常用 Gradle 命令

| 命令 | 说明 |
|------|------|
| `gradle tasks` | 列出所有可用任务 |
| `gradle build` | 构建项目 |
| `gradle clean` | 清理构建输出 |
| `gradle test` | 运行测试 |
| `gradle assemble` | 组装项目输出（不运行测试）|
| `gradle dependencies` | 显示依赖树 |
| `gradle --refresh-dependencies` | 强制刷新依赖 |
| `gradle wrapper --gradle-version X.X` | 更新 Gradle Wrapper 版本（例如：8.5）|
| `./gradlew build` | 使用 Wrapper 构建项目 |

### Mac M 芯片注意事项

1. **Java 版本兼容性**: 
   - Gradle 需要 Java 8 或更高版本
   - 推荐使用 Java 17 或 Java 21（LTS 版本）
   - 如果使用 jenv，确保启用了 gradle 插件：`jenv enable-plugin gradle`

2. **性能优化**:
   - Apple Silicon Mac 使用原生 ARM64 Java 可以获得最佳性能
   - 在 `gradle.properties` 中适当增加 JVM 内存配置

3. **并行构建**:
   - M 系列芯片具有多核心，启用并行构建可以显著提升构建速度
   - 已在上述配置中启用 `org.gradle.parallel=true`

4. **文件系统监控**:
   - macOS 支持文件系统事件监控，启用 `org.gradle.vfs.watch=true` 可以提升增量构建性能

### Android 开发特别说明

如果您使用 Gradle 进行 Android 开发，还需要配置 Android SDK 和 NDK：

```properties
# 在 ~/.gradle/gradle.properties 中添加
# 将 YOUR_USERNAME 替换为您的用户名
sdk.dir=/Users/YOUR_USERNAME/Library/Android/sdk
# 将 VERSION 替换为您安装的 NDK 版本号，例如 25.2.9519653
ndk.dir=/Users/YOUR_USERNAME/Library/Android/sdk/ndk/VERSION
```

或者设置环境变量：

```bash
# 添加到 ~/.zshrc
export ANDROID_HOME=$HOME/Library/Android/sdk
# 将 VERSION 替换为您安装的 NDK 版本号
export ANDROID_NDK_HOME=$ANDROID_HOME/ndk/VERSION
export PATH=$PATH:$ANDROID_HOME/tools:$ANDROID_HOME/platform-tools
```

### 故障排除

#### Gradle 守护进程问题

如果遇到守护进程问题，可以停止所有守护进程：

```bash
gradle --stop
```

#### 清理 Gradle 缓存

```bash
rm -rf ~/.gradle/caches
```

#### 权限问题

确保 Gradle 目录有正确的权限：

```bash
chmod -R 755 ~/.gradle
```

---

## 参考资料

- [nvm GitHub](https://github.com/nvm-sh/nvm)
- [pyenv GitHub](https://github.com/pyenv/pyenv)
- [Homebrew 官网](https://brew.sh/)
- [jenv GitHub](https://github.com/jenv/jenv)
- [Oracle JDK 下载](https://www.oracle.com/java/technologies/downloads/)
- [Azul Zulu JDK 官网](https://www.azul.com/downloads/)
- [Apache Maven 官网](https://maven.apache.org/)
- [Gradle 官网](https://gradle.org/)
- [阿里云 Maven 镜像](https://developer.aliyun.com/mirror/maven)
- [腾讯云 Maven 镜像](https://mirrors.cloud.tencent.com/)
