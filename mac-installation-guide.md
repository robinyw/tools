# Mac 开发环境安装指南

本文档提供在 macOS 上安装 npm、Python 和 Java 的详细指南。对于 npm 和 Python，我们将安装版本管理工具，以便轻松切换不同版本。

## 目录
- [安装 Homebrew](#安装-homebrew)
- [安装 npm (使用 nvm)](#安装-npm-使用-nvm)
- [安装 Python (使用 pyenv)](#安装-python-使用-pyenv)
- [安装 Java](#安装-java)

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

这些工具将帮助您轻松管理和切换不同版本，以满足不同项目的需求。

---

## 参考资料

- [nvm GitHub](https://github.com/nvm-sh/nvm)
- [pyenv GitHub](https://github.com/pyenv/pyenv)
- [Homebrew 官网](https://brew.sh/)
- [jenv GitHub](https://github.com/jenv/jenv)
- [Oracle JDK 下载](https://www.oracle.com/java/technologies/downloads/)
