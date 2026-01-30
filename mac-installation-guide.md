# Mac 开发环境安装指南

本文档提供在 macOS 上安装 Git、npm、Python 和 Java 的详细指南。对于 npm 和 Python，我们将安装版本管理工具，以便轻松切换不同版本。

## 目录
- [安装 Homebrew](#安装-homebrew)
- [安装 Git](#安装-git)
- [安装 npm (使用 nvm)](#安装-npm-使用-nvm)
- [安装 Python (使用 pyenv)](#安装-python-使用-pyenv)
- [安装 Java](#安装-java)
- [安装 Zulu JDK (Mac M 芯片推荐)](#安装-zulu-jdk-mac-m-芯片推荐)
- [安装和配置 Maven](#安装和配置-maven)
- [安装和配置 Gradle](#安装和配置-gradle)

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

## 安装 Git

Git 是一个分布式版本控制系统，是现代软件开发的必备工具。macOS 提供了多种安装 Git 的方法。

### 方法 1: 使用 Xcode Command Line Tools 安装 (推荐)

这是最简单的方法，macOS 会自动安装 Apple 提供的 Git 版本。

#### 1. 检查是否已安装 Git

```bash
git --version
```

如果未安装，系统会自动提示安装 Command Line Tools。

#### 2. 手动安装 Command Line Tools

如果没有自动提示，可以手动安装：

```bash
xcode-select --install
```

这将打开一个对话框，点击"安装"按钮即可。

#### 3. 验证安装

```bash
git --version
```

输出示例：
```
git version 2.39.2 (Apple Git-143)
```

### 方法 2: 使用 Homebrew 安装 (推荐获取最新版本)

使用 Homebrew 可以获得最新版本的 Git，并且更容易升级。

#### 1. 安装 Git

```bash
brew install git
```

#### 2. 验证安装

```bash
git --version
```

输出示例：
```
git version 2.43.0
```

#### 3. 升级 Git

```bash
brew upgrade git
```

### 方法 3: 下载官方安装包

1. 访问 [Git 官方网站](https://git-scm.com/download/mac)
2. 下载适用于 macOS 的安装包
3. 运行安装程序并按照提示操作

### 初始配置 Git

安装 Git 后，需要配置您的用户信息。这些信息会用于每次提交。

#### 1. 配置用户名和邮箱

```bash
git config --global user.name "您的名字"
git config --global user.email "your.email@example.com"
```

#### 2. 配置默认分支名称

将默认分支名称设置为 `main`：

```bash
git config --global init.defaultBranch main
```

#### 3. 配置编辑器

设置默认文本编辑器（例如使用 vim）：

```bash
git config --global core.editor vim
```

或使用 nano：

```bash
git config --global core.editor nano
```

或使用 VS Code（如果已安装）：

```bash
git config --global core.editor "code --wait"
```

#### 4. 启用颜色输出

```bash
git config --global color.ui auto
```

#### 5. 配置换行符处理

对于 macOS/Linux 用户：

```bash
git config --global core.autocrlf input
```

#### 6. 查看所有配置

```bash
git config --list
```

或查看全局配置文件：

```bash
cat ~/.gitconfig
```

### 配置 SSH 密钥（用于 GitHub/GitLab）

#### 1. 检查现有 SSH 密钥

```bash
ls -al ~/.ssh
```

查看是否存在 `id_rsa.pub` 或 `id_ed25519.pub` 文件。

#### 2. 生成新的 SSH 密钥

如果没有 SSH 密钥，生成一个新的：

使用 Ed25519 算法（推荐）：

```bash
ssh-keygen -t ed25519 -C "your.email@example.com"
```

或使用 RSA 算法：

```bash
ssh-keygen -t rsa -b 4096 -C "your.email@example.com"
```

按 Enter 使用默认文件位置，然后设置密码（可选）。

#### 3. 添加 SSH 密钥到 ssh-agent

启动 ssh-agent：

```bash
eval "$(ssh-agent -s)"
```

配置 SSH 以自动加载密钥（编辑 `~/.ssh/config`）：

```bash
nano ~/.ssh/config
```

添加以下内容（根据您生成的密钥类型调整 IdentityFile）：

对于 Ed25519 密钥：

```
Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_ed25519
```

对于 RSA 密钥：

```
Host *
  AddKeysToAgent yes
  UseKeychain yes
  IdentityFile ~/.ssh/id_rsa
```

添加私钥到 ssh-agent：

对于 macOS 12 及更高版本：

```bash
ssh-add ~/.ssh/id_ed25519
```

对于 macOS 11 及更早版本：

```bash
ssh-add --apple-use-keychain ~/.ssh/id_ed25519
```

#### 4. 复制公钥

```bash
pbcopy < ~/.ssh/id_ed25519.pub
```

然后将公钥添加到您的 GitHub、GitLab 或其他 Git 托管平台的账户设置中。

#### 5. 测试 SSH 连接

测试 GitHub 连接：

```bash
ssh -T git@github.com
```

测试 GitLab 连接：

```bash
ssh -T git@gitlab.com
```

成功的输出示例：
```
Hi username! You've successfully authenticated, but GitHub does not provide shell access.
```

### 配置 Git 凭证助手

为了避免每次推送时都输入密码，可以配置凭证助手。

#### macOS Keychain 凭证助手

macOS 自带 keychain 凭证助手：

```bash
git config --global credential.helper osxkeychain
```

这将把您的 Git 凭证（用户名和密码）保存在 macOS 钥匙串中。

### 常用 Git 别名配置（可选）

为常用命令设置别名以提高效率：

```bash
# 常用别名
git config --global alias.st status
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.unstage 'restore --staged'
git config --global alias.last 'log -1 HEAD'
git config --global alias.lg 'log --graph --pretty=format:"%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset" --abbrev-commit'
```

使用示例：
```bash
git st          # 等同于 git status
git co main     # 等同于 git checkout main
git ci -m "msg" # 等同于 git commit -m "msg"
git lg          # 美化的 log 输出
```

### 全局 .gitignore 配置（可选）

创建全局 `.gitignore` 文件以忽略常见的系统文件：

#### 1. 创建全局 .gitignore 文件

```bash
nano ~/.gitignore_global
```

#### 2. 添加常见的 macOS 和编辑器文件

```
# macOS 系统文件
.DS_Store
.AppleDouble
.LSOverride

# macOS 缩略图
._*

# macOS 文件夹属性
.DocumentRevisions-V100
.fseventsd
.Spotlight-V100
.TemporaryItems
.Trashes
.VolumeIcon.icns
.com.apple.timemachine.donotpresent

# 编辑器
.idea/
.vscode/
*.swp
*.swo
*~

# Node
node_modules/
npm-debug.log

# Python
__pycache__/
*.py[cod]
*.egg-info/
.pytest_cache/
venv/
.env
```

#### 3. 配置 Git 使用全局 .gitignore

```bash
git config --global core.excludesfile ~/.gitignore_global
```

### 验证 Git 配置

运行以下命令验证 Git 配置：

```bash
# 查看 Git 版本
git --version

# 查看用户配置
git config user.name
git config user.email

# 查看所有全局配置
git config --global --list
```

### 常用 Git 命令

| 命令 | 说明 |
|------|------|
| `git init` | 初始化一个新的 Git 仓库 |
| `git clone <url>` | 克隆远程仓库 |
| `git status` | 查看工作区状态 |
| `git add <file>` | 添加文件到暂存区 |
| `git add .` | 添加所有更改到暂存区 |
| `git commit -m "message"` | 提交更改 |
| `git push` | 推送到远程仓库 |
| `git pull` | 拉取并合并远程更改 |
| `git branch` | 列出分支 |
| `git checkout -b <branch>` | 创建并切换到新分支 |
| `git merge <branch>` | 合并分支 |
| `git log` | 查看提交历史 |
| `git diff` | 查看更改 |

### Git GUI 工具推荐（可选）

如果您喜欢图形界面，可以使用以下 Git GUI 工具：

1. **GitHub Desktop** - GitHub 官方客户端
   ```bash
   brew install --cask github
   ```

2. **Sourcetree** - 功能强大的 Git GUI
   ```bash
   brew install --cask sourcetree
   ```

3. **GitKraken** - 现代化的 Git 客户端
   ```bash
   brew install --cask gitkraken
   ```

4. **Tower** - 专业的 macOS Git 客户端
   ```bash
   brew install --cask tower
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

## 安装 Zulu JDK (Mac M 芯片推荐)

Zulu JDK 是由 Azul Systems 提供的 OpenJDK 发行版，针对 Apple Silicon (M1/M2/M3) 芯片进行了优化，性能更好。

### 为什么选择 Zulu JDK for Mac M 芯片？

- 专门针对 ARM64 架构（Apple Silicon）优化
- 完全兼容 OpenJDK 标准
- 提供长期支持（LTS）版本
- 性能优于传统 x86 版本通过 Rosetta 2 运行

### 方法 1: 使用 Homebrew 安装 Zulu JDK (推荐)

#### 1. 添加 Zulu tap

```bash
brew tap mdogan/zulu
```

#### 2. 安装 Zulu JDK

安装最新版本：

```bash
brew install --cask zulu
```

安装特定版本（推荐安装多个版本）：

```bash
# Zulu JDK 8
brew install --cask zulu-jdk8

# Zulu JDK 11 (LTS)
brew install --cask zulu-jdk11

# Zulu JDK 17 (LTS)
brew install --cask zulu-jdk17

# Zulu JDK 21 (LTS)
brew install --cask zulu-jdk21
```

#### 3. 验证安装

```bash
# 查看所有已安装的 Java 版本
/usr/libexec/java_home -V
```

输出示例：
```
Matching Java Virtual Machines (4):
    21.0.1 (arm64) "Azul Systems, Inc." - "Zulu 21.30.15" /Library/Java/JavaVirtualMachines/zulu-21.jdk/Contents/Home
    17.0.9 (arm64) "Azul Systems, Inc." - "Zulu 17.46.19" /Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home
    11.0.21 (arm64) "Azul Systems, Inc." - "Zulu 11.68.17" /Library/Java/JavaVirtualMachines/zulu-11.jdk/Contents/Home
    1.8.0_392 (arm64) "Azul Systems, Inc." - "Zulu 8.74.0.17" /Library/Java/JavaVirtualMachines/zulu-8.jdk/Contents/Home
```

### 方法 2: 手动下载安装

1. 访问 [Azul Zulu 下载页面](https://www.azul.com/downloads/?package=jdk)
2. 选择以下选项：
   - **Java Version**: 选择所需版本（8、11、17、21 等）
   - **Operating System**: macOS
   - **Architecture**: ARM 64-bit (for M1/M2/M3)
   - **Java Package**: JDK
3. 下载 .dmg 文件并安装

### 配置多版本 Java 环境

#### 方法 1: 使用 jenv 管理多个 Zulu JDK 版本 (强烈推荐)

##### 1. 安装 jenv

```bash
brew install jenv
```

##### 2. 配置 jenv

将以下内容添加到您的 shell 配置文件（`~/.zshrc` 或 `~/.bash_profile`）：

```bash
export PATH="$HOME/.jenv/bin:$PATH"
eval "$(jenv init -)"
# 启用 jenv 的 Maven 和 Gradle 插件
jenv enable-plugin maven
jenv enable-plugin gradle
jenv enable-plugin export
```

重新加载配置文件：

```bash
source ~/.zshrc  # 如果使用 zsh
```

##### 3. 添加已安装的 Zulu JDK 到 jenv

```bash
# 添加 Zulu JDK 8
jenv add /Library/Java/JavaVirtualMachines/zulu-8.jdk/Contents/Home

# 添加 Zulu JDK 11
jenv add /Library/Java/JavaVirtualMachines/zulu-11.jdk/Contents/Home

# 添加 Zulu JDK 17
jenv add /Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home

# 添加 Zulu JDK 21
jenv add /Library/Java/JavaVirtualMachines/zulu-21.jdk/Contents/Home
```

##### 4. 查看和管理 Java 版本

```bash
# 列出所有可用的 Java 版本
jenv versions

# 设置全局默认版本（推荐使用 LTS 版本）
jenv global 17.0

# 为当前目录设置特定版本
jenv local 11.0

# 为当前 shell 会话设置版本
jenv shell 21.0
```

##### 5. 验证当前 Java 版本

```bash
java -version
javac -version
echo $JAVA_HOME
```

#### 方法 2: 使用脚本快速切换 Java 版本

将以下函数添加到您的 `~/.zshrc` 或 `~/.bash_profile`：

```bash
# 快速切换 Java 版本的函数
jdk() {
    version=$1
    export JAVA_HOME=$(/usr/libexec/java_home -v"$version");
    java -version
}
```

使用方法：

```bash
# 切换到 Java 8
jdk 1.8

# 切换到 Java 11
jdk 11

# 切换到 Java 17
jdk 17

# 切换到 Java 21
jdk 21
```

### 验证 Zulu JDK 安装

```bash
java -version
```

输出应显示 "Zulu" 字样，例如：
```
openjdk version "17.0.9" 2023-10-17 LTS
OpenJDK Runtime Environment Zulu17.46+19-CA (build 17.0.9+8-LTS)
OpenJDK 64-Bit Server VM Zulu17.46+19-CA (build 17.0.9+8-LTS, mixed mode, sharing)
```

### 常用 jenv 命令

| 命令 | 说明 |
|------|------|
| `jenv versions` | 列出所有已添加的 Java 版本 |
| `jenv global <version>` | 设置全局默认 Java 版本 |
| `jenv local <version>` | 为当前目录设置 Java 版本 |
| `jenv shell <version>` | 为当前 shell 会话设置 Java 版本 |
| `jenv add <path>` | 添加 Java 版本到 jenv |
| `jenv remove <version>` | 从 jenv 移除 Java 版本 |
| `jenv which java` | 显示当前 Java 可执行文件的路径 |
| `jenv enable-plugin <name>` | 启用 jenv 插件 |

---

## 安装和配置 Maven

Apache Maven 是一个项目管理和构建自动化工具，主要用于 Java 项目。

### 安装 Maven

#### 方法 1: 使用 Homebrew 安装 (推荐)

```bash
brew install maven
```

#### 方法 2: 手动安装

1. 访问 [Maven 下载页面](https://maven.apache.org/download.cgi)
2. 下载二进制压缩包（apache-maven-x.x.x-bin.tar.gz）
3. 解压到指定目录：

```bash
sudo tar -xzvf apache-maven-3.9.6-bin.tar.gz -C /opt
sudo ln -s /opt/apache-maven-3.9.6 /opt/maven
```

4. 配置环境变量（添加到 `~/.zshrc` 或 `~/.bash_profile`）：

```bash
export MAVEN_HOME=/opt/maven
export PATH=$MAVEN_HOME/bin:$PATH
```

5. 重新加载配置文件：

```bash
source ~/.zshrc
```

### 验证 Maven 安装

```bash
mvn -version
```

输出应显示 Maven 版本、Java 版本和操作系统信息。

### 配置 Maven

#### 1. 创建或编辑 settings.xml

Maven 的配置文件位于 `~/.m2/settings.xml`。如果文件不存在，创建它：

```bash
mkdir -p ~/.m2
nano ~/.m2/settings.xml
```

#### 2. 配置本地仓库位置和远程仓库镜像

将以下内容添加到 `settings.xml`：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                              http://maven.apache.org/xsd/settings-1.0.0.xsd">
  
  <!-- 本地仓库路径 -->
  <localRepository>${user.home}/.m2/repository</localRepository>

  <!-- 镜像配置 -->
  <mirrors>
    <!-- 阿里云 Maven 中央仓库镜像 (推荐中国用户使用) -->
    <mirror>
      <id>aliyun-central</id>
      <mirrorOf>central</mirrorOf>
      <name>Aliyun Maven Central</name>
      <url>https://maven.aliyun.com/repository/central</url>
    </mirror>
    
    <!-- 阿里云公共仓库 (包含更多第三方库) -->
    <mirror>
      <id>aliyun-public</id>
      <mirrorOf>public</mirrorOf>
      <name>Aliyun Maven Public</name>
      <url>https://maven.aliyun.com/repository/public</url>
    </mirror>
    
    <!-- Maven 中央仓库（如果不在中国，可以使用此配置） -->
    <!--
    <mirror>
      <id>maven-central</id>
      <mirrorOf>central</mirrorOf>
      <name>Maven Central Repository</name>
      <url>https://repo.maven.apache.org/maven2</url>
    </mirror>
    -->
  </mirrors>

  <!-- 代理配置 (如果需要通过代理访问互联网) -->
  <!--
  <proxies>
    <proxy>
      <id>my-proxy</id>
      <active>true</active>
      <protocol>http</protocol>
      <host>proxy.example.com</host>
      <port>8080</port>
      <username>proxyuser</username>
      <password>proxypass</password>
      <nonProxyHosts>localhost|127.0.0.1</nonProxyHosts>
    </proxy>
  </proxies>
  -->

  <!-- 服务器认证配置 (用于私有仓库) -->
  <!--
  <servers>
    <server>
      <id>private-repo</id>
      <username>your-username</username>
      <password>your-password</password>
    </server>
  </servers>
  -->

  <!-- 配置文件 -->
  <profiles>
    <!-- JDK 版本配置 -->
    <profile>
      <id>jdk-17</id>
      <activation>
        <activeByDefault>true</activeByDefault>
        <jdk>17</jdk>
      </activation>
      <properties>
        <maven.compiler.source>17</maven.compiler.source>
        <maven.compiler.target>17</maven.compiler.target>
        <maven.compiler.compilerVersion>17</maven.compiler.compilerVersion>
      </properties>
    </profile>

    <!-- 阿里云仓库配置 -->
    <profile>
      <id>aliyun-repos</id>
      <repositories>
        <repository>
          <id>aliyun-central</id>
          <name>Aliyun Maven Central</name>
          <url>https://maven.aliyun.com/repository/central</url>
          <releases>
            <enabled>true</enabled>
          </releases>
          <snapshots>
            <enabled>false</enabled>
          </snapshots>
        </repository>
        <repository>
          <id>aliyun-public</id>
          <name>Aliyun Maven Public</name>
          <url>https://maven.aliyun.com/repository/public</url>
          <releases>
            <enabled>true</enabled>
          </releases>
          <snapshots>
            <enabled>false</enabled>
          </snapshots>
        </repository>
        <repository>
          <id>aliyun-spring</id>
          <name>Aliyun Maven Spring</name>
          <url>https://maven.aliyun.com/repository/spring</url>
          <releases>
            <enabled>true</enabled>
          </releases>
          <snapshots>
            <enabled>false</enabled>
          </snapshots>
        </repository>
      </repositories>
      <pluginRepositories>
        <pluginRepository>
          <id>aliyun-plugin</id>
          <name>Aliyun Maven Plugin</name>
          <url>https://maven.aliyun.com/repository/central</url>
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
    <activeProfile>aliyun-repos</activeProfile>
  </activeProfiles>

</settings>
```

#### 3. 验证配置

```bash
# 查看有效的 settings
mvn help:effective-settings

# 测试下载依赖
mvn dependency:get -Dartifact=org.apache.commons:commons-lang3:3.12.0
```

### 其他常用 Maven 配置

#### 配置 Maven 使用特定 Java 版本

如果使用 jenv，Maven 会自动使用 jenv 配置的 Java 版本。否则，可以在 `~/.mavenrc` 中配置：

```bash
# 创建 .mavenrc 文件
echo 'JAVA_HOME=$(/usr/libexec/java_home -v 17)' > ~/.mavenrc
```

#### 增加 Maven 内存

在 `~/.mavenrc` 中添加：

```bash
export MAVEN_OPTS="-Xms512m -Xmx2048m"
```

### 常用 Maven 命令

| 命令 | 说明 |
|------|------|
| `mvn clean` | 清理项目（删除 target 目录） |
| `mvn compile` | 编译项目源代码 |
| `mvn test` | 运行单元测试 |
| `mvn package` | 打包项目（生成 JAR 或 WAR 文件） |
| `mvn install` | 安装到本地仓库 |
| `mvn deploy` | 部署到远程仓库 |
| `mvn clean install` | 清理并安装项目 |
| `mvn dependency:tree` | 查看依赖树 |
| `mvn versions:display-dependency-updates` | 检查依赖更新 |

---

## 安装和配置 Gradle

Gradle 是一个现代化的构建自动化工具，广泛用于 Java、Android 和其他项目。

### 安装 Gradle

#### 方法 1: 使用 Homebrew 安装 (推荐)

```bash
brew install gradle
```

#### 方法 2: 使用 SDKMAN! 安装 (推荐用于管理多版本)

SDKMAN! 是一个管理多个软件开发工具包版本的工具。

##### 1. 安装 SDKMAN!

```bash
curl -s "https://get.sdkman.io" | bash
source "$HOME/.sdkman/bin/sdkman-init.sh"
```

##### 2. 验证 SDKMAN! 安装

```bash
sdk version
```

##### 3. 使用 SDKMAN! 安装 Gradle

```bash
# 查看可用的 Gradle 版本
sdk list gradle

# 安装最新版本
sdk install gradle

# 安装特定版本
sdk install gradle 8.5
sdk install gradle 7.6
```

##### 4. 切换 Gradle 版本

```bash
# 列出已安装的版本
sdk list gradle

# 切换默认版本
sdk default gradle 8.5

# 临时使用特定版本
sdk use gradle 7.6
```

#### 方法 3: 手动安装

1. 访问 [Gradle 下载页面](https://gradle.org/releases/)
2. 下载二进制压缩包（gradle-x.x-bin.zip）
3. 解压到指定目录：

```bash
sudo unzip gradle-8.5-bin.zip -d /opt
sudo ln -s /opt/gradle-8.5 /opt/gradle
```

4. 配置环境变量（添加到 `~/.zshrc` 或 `~/.bash_profile`）：

```bash
export GRADLE_HOME=/opt/gradle
export PATH=$GRADLE_HOME/bin:$PATH
```

5. 重新加载配置文件：

```bash
source ~/.zshrc
```

### 验证 Gradle 安装

```bash
gradle -version
```

### 配置 Gradle

#### 1. 创建全局配置文件

Gradle 的全局配置文件位于 `~/.gradle/gradle.properties`：

```bash
mkdir -p ~/.gradle
nano ~/.gradle/gradle.properties
```

#### 2. 配置 Gradle 属性

将以下内容添加到 `gradle.properties`：

```properties
# 编译配置
org.gradle.daemon=true
org.gradle.parallel=true
org.gradle.caching=true

# 内存配置 (根据您的 Mac 配置调整)
org.gradle.jvmargs=-Xmx4g -XX:MaxMetaspaceSize=512m -XX:+HeapDumpOnOutOfMemoryError

# 文件编码
file.encoding=UTF-8

# Gradle 缓存配置
org.gradle.configuration-cache=true

# 配置仓库镜像（如果项目允许）
systemProp.https.proxyHost=
systemProp.https.proxyPort=
systemProp.http.proxyHost=
systemProp.http.proxyPort=
```

#### 3. 配置仓库镜像

##### 方法 1: 在项目的 build.gradle 中配置 (Groovy DSL)

编辑项目的 `build.gradle` 文件：

```groovy
allprojects {
    repositories {
        // 阿里云 Maven 中央仓库镜像
        maven { url 'https://maven.aliyun.com/repository/central' }
        maven { url 'https://maven.aliyun.com/repository/public' }
        maven { url 'https://maven.aliyun.com/repository/google' }
        maven { url 'https://maven.aliyun.com/repository/gradle-plugin' }
        
        // 如果需要，可以保留原始仓库作为备选
        mavenCentral()
        google()
        gradlePluginPortal()
    }
}
```

##### 方法 2: 在项目的 build.gradle.kts 中配置 (Kotlin DSL)

编辑项目的 `build.gradle.kts` 文件：

```kotlin
allprojects {
    repositories {
        // 阿里云 Maven 中央仓库镜像
        maven { url = uri("https://maven.aliyun.com/repository/central") }
        maven { url = uri("https://maven.aliyun.com/repository/public") }
        maven { url = uri("https://maven.aliyun.com/repository/google") }
        maven { url = uri("https://maven.aliyun.com/repository/gradle-plugin") }
        
        // 如果需要，可以保留原始仓库作为备选
        mavenCentral()
        google()
        gradlePluginPortal()
    }
}
```

##### 方法 3: 使用 init.gradle 全局配置 (影响所有项目)

创建 `~/.gradle/init.gradle` 文件：

```bash
nano ~/.gradle/init.gradle
```

添加以下内容：

```groovy
allprojects {
    repositories {
        all { ArtifactRepository repo ->
            if (repo instanceof MavenArtifactRepository) {
                def url = repo.url.toString()
                // 替换 Maven 中央仓库
                if (url.startsWith('https://repo1.maven.org/maven2') || 
                    url.startsWith('https://repo.maven.apache.org/maven2')) {
                    project.logger.lifecycle "Repository ${repo.url} replaced by Aliyun Maven Central."
                    remove repo
                }
                // 替换 Google 仓库
                if (url.startsWith('https://dl.google.com/dl/android/maven2')) {
                    project.logger.lifecycle "Repository ${repo.url} replaced by Aliyun Google."
                    remove repo
                }
                // 替换 Gradle 插件仓库
                if (url.startsWith('https://plugins.gradle.org/m2')) {
                    project.logger.lifecycle "Repository ${repo.url} replaced by Aliyun Gradle Plugin."
                    remove repo
                }
            }
        }
        
        // 添加阿里云镜像
        maven { url 'https://maven.aliyun.com/repository/central' }
        maven { url 'https://maven.aliyun.com/repository/public' }
        maven { url 'https://maven.aliyun.com/repository/google' }
        maven { url 'https://maven.aliyun.com/repository/gradle-plugin' }
        maven { url 'https://maven.aliyun.com/repository/spring' }
        maven { url 'https://maven.aliyun.com/repository/spring-plugin' }
    }
    
    buildscript {
        repositories {
            maven { url 'https://maven.aliyun.com/repository/central' }
            maven { url 'https://maven.aliyun.com/repository/public' }
            maven { url 'https://maven.aliyun.com/repository/google' }
            maven { url 'https://maven.aliyun.com/repository/gradle-plugin' }
        }
    }
}

settingsEvaluated { settings ->
    settings.pluginManagement {
        repositories {
            maven { url 'https://maven.aliyun.com/repository/gradle-plugin' }
            maven { url 'https://maven.aliyun.com/repository/central' }
            maven { url 'https://maven.aliyun.com/repository/public' }
            gradlePluginPortal()
            mavenCentral()
        }
    }
}
```

#### 4. 配置 Gradle Wrapper

对于使用 Gradle Wrapper 的项目，可以配置 wrapper 的下载源。

编辑项目的 `gradle/wrapper/gradle-wrapper.properties`：

```properties
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
# 使用阿里云镜像下载 Gradle
distributionUrl=https\://mirrors.cloud.tencent.com/gradle/gradle-8.5-bin.zip
# 或使用官方源
# distributionUrl=https\://services.gradle.org/distributions/gradle-8.5-bin.zip
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
```

### 配置 Gradle 使用特定 Java 版本

#### 方法 1: 在项目中配置 (推荐)

编辑 `build.gradle`：

```groovy
java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(17)
    }
}
```

或在 `build.gradle.kts`：

```kotlin
java {
    toolchain {
        languageVersion.set(JavaLanguageVersion.of(17))
    }
}
```

#### 方法 2: 使用 jenv (如果已安装)

Gradle 会自动使用 jenv 配置的 Java 版本（需要启用 jenv 的 gradle 插件）。

```bash
jenv enable-plugin gradle
```

#### 方法 3: 通过环境变量

```bash
# 临时设置
export JAVA_HOME=$(/usr/libexec/java_home -v 17)

# 或使用 jdk 函数（如果已配置）
jdk 17
```

### 验证配置

```bash
# 查看 Gradle 信息
gradle -version

# 测试构建（在有 Gradle 项目的目录中）
gradle build --scan

# 查看依赖
gradle dependencies
```

### 常用 Gradle 命令

| 命令 | 说明 |
|------|------|
| `gradle build` | 构建项目 |
| `gradle clean` | 清理构建输出 |
| `gradle test` | 运行测试 |
| `gradle tasks` | 列出所有可用任务 |
| `gradle dependencies` | 显示项目依赖 |
| `gradle wrapper` | 生成 Gradle Wrapper |
| `gradle --refresh-dependencies` | 刷新依赖 |
| `gradle build --scan` | 构建并生成构建扫描报告 |
| `./gradlew build` | 使用 Wrapper 构建（推荐） |

### Gradle vs Maven 对比

| 特性 | Gradle | Maven |
|------|--------|-------|
| 配置文件 | build.gradle / build.gradle.kts | pom.xml |
| 配置语言 | Groovy / Kotlin DSL | XML |
| 性能 | 更快（增量构建、构建缓存） | 较慢 |
| 灵活性 | 非常灵活 | 约定优于配置 |
| 学习曲线 | 较陡峭 | 较平缓 |
| 生态系统 | Android 官方推荐 | Java 企业级首选 |

---

## 验证所有安装

运行以下命令以验证所有工具都已正确安装：

```bash
# Git
git --version
git config user.name
git config user.email

# Node.js 和 npm
node --version
npm --version
nvm --version

# Python
python --version
pyenv --version

# Java (Zulu JDK)
java -version
echo $JAVA_HOME
jenv versions  # 如果使用 jenv

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

现在您已经在 macOS (特别是 Mac M 芯片) 上成功安装了：
- **Git**（版本控制系统）
- **npm** 和 **nvm**（Node.js 版本管理器）
- **Python** 和 **pyenv**（Python 版本管理器）
- **Java**（可选使用 jenv 进行版本管理）
- **Zulu JDK**（针对 Apple Silicon 优化的 JDK，支持多版本管理）
- **Maven**（配置了阿里云镜像，加快依赖下载速度）
- **Gradle**（配置了仓库镜像和性能优化）

这些工具将帮助您轻松管理和切换不同版本，以满足不同项目的需求。

### 推荐的开发环境配置

对于 Mac M 芯片用户，推荐以下配置：

1. **Java 开发**：使用 Zulu JDK + jenv 管理多版本
2. **构建工具**：
   - 企业级项目：Maven（配置阿里云镜像）
   - Android/现代 Java 项目：Gradle（配置阿里云镜像）
3. **IDE**：IntelliJ IDEA 或 VS Code（均原生支持 Apple Silicon）

---

## 参考资料

- [nvm GitHub](https://github.com/nvm-sh/nvm)
- [pyenv GitHub](https://github.com/pyenv/pyenv)
- [Homebrew 官网](https://brew.sh/)
- [jenv GitHub](https://github.com/jenv/jenv)
- [Oracle JDK 下载](https://www.oracle.com/java/technologies/downloads/)
- [Azul Zulu JDK 下载](https://www.azul.com/downloads/?package=jdk)
- [Maven 官网](https://maven.apache.org/)
- [Gradle 官网](https://gradle.org/)
- [SDKMAN! 官网](https://sdkman.io/)
- [阿里云 Maven 镜像](https://developer.aliyun.com/mirror/maven)
