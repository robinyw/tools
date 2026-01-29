# Mac 虚拟机安装指南

本文档提供在 macOS 上安装虚拟机的详细指南，涵盖主流虚拟机方案的比较和具体安装步骤。

## 目录
- [虚拟机方案概览](#虚拟机方案概览)
- [主流方案推荐](#主流方案推荐)
- [Parallels Desktop 安装指南](#parallels-desktop-安装指南)
- [UTM 安装指南（Apple Silicon）](#utm-安装指南apple-silicon)
- [常见问题](#常见问题)

---

## 虚拟机方案概览

在 Mac 上运行虚拟机有多种方案可选，以下是主要的虚拟机解决方案：

### 1. Parallels Desktop
- **类型**: 商业软件（付费）
- **优势**: 
  - 性能优秀，与 macOS 集成度高
  - 支持 Intel 和 Apple Silicon (M1/M2/M3) Mac
  - 用户界面友好，易于使用
  - 支持 Windows、Linux 等多种操作系统
  - Coherence 模式可以无缝集成 Windows 应用
- **劣势**: 
  - 需要购买许可证（约 $99.99/年）
  - 不开源
- **适用场景**: 需要最佳性能和用户体验的专业用户

### 2. VMware Fusion
- **类型**: 商业软件（个人使用免费）
- **优势**:
  - 功能强大，企业级虚拟化技术
  - 2024 年起个人使用免费
  - 支持 Intel 和 Apple Silicon Mac
  - 与 VMware 生态系统兼容
- **劣势**:
  - 界面相对复杂
  - Apple Silicon 支持仍在完善中
- **适用场景**: 企业用户和需要 VMware 生态的用户

### 3. VirtualBox
- **类型**: 开源免费软件
- **优势**:
  - 完全免费且开源
  - 跨平台支持（Windows、Mac、Linux）
  - 社区活跃，文档丰富
- **劣势**:
  - **不支持 Apple Silicon Mac**（仅支持 Intel Mac）
  - 性能相对较低
  - 与 macOS 集成度较低
- **适用场景**: Intel Mac 用户且预算有限

### 4. UTM
- **类型**: 开源免费软件
- **优势**:
  - 完全免费且开源
  - **专为 Apple Silicon 优化**
  - 支持 Intel 和 Apple Silicon Mac
  - 使用 QEMU 和苹果的虚拟化框架
  - 界面简洁，易于使用
  - App Store 版本支持 iOS 设备
- **劣势**:
  - 相比商业软件，功能较为基础
  - 某些高级功能需要手动配置
- **适用场景**: Apple Silicon Mac 用户，开源爱好者

### 5. QEMU
- **类型**: 开源命令行工具
- **优势**:
  - 完全免费且开源
  - 功能强大，高度可定制
  - 支持多种架构
- **劣势**:
  - 需要命令行操作，学习曲线陡峭
  - 没有图形界面
  - 配置复杂
- **适用场景**: 高级用户和开发者

---

## 主流方案推荐

根据目前市场使用情况和用户反馈，我们推荐以下两种主流方案：

### 推荐方案 1: Parallels Desktop（商业方案）
**适用于**: 需要最佳性能和用户体验，预算充足的用户
- 支持 Intel 和 Apple Silicon Mac
- 性能最优，功能最全
- 适合专业用户和企业用户

### 推荐方案 2: UTM（免费方案）
**适用于**: Apple Silicon Mac 用户，预算有限或开源爱好者
- 完全免费且开源
- 专为 Apple Silicon 优化
- 适合个人用户和学习使用

> **注意**: 如果您使用的是 Intel Mac 且预算有限，可以选择 VirtualBox 或免费版的 VMware Fusion。

下面我们将详细介绍这两种主流方案的安装步骤。

---

## Parallels Desktop 安装指南

Parallels Desktop 是 Mac 上最流行的商业虚拟机软件，提供出色的性能和用户体验。同时支持 Intel 和 Apple Silicon Mac。

### 系统要求

- macOS 12.0 (Monterey) 或更高版本
- 至少 4GB RAM（推荐 8GB 或更多）
- 至少 600MB 可用磁盘空间用于安装 Parallels Desktop
- 额外的磁盘空间用于虚拟机（根据客户操作系统而定，通常 20-60GB）
- Intel 处理器或 Apple Silicon (M1/M2/M3)

### 安装步骤

#### 1. 下载并安装 Parallels Desktop

**方法 1: 使用 Homebrew 安装（推荐）**

```bash
brew install --cask parallels
```

**方法 2: 手动安装**

访问 [Parallels Desktop 官网](https://www.parallels.com/products/desktop/) 下载 .dmg 文件，然后：

1. 打开下载的 `.dmg` 文件
2. 双击 `Install Parallels Desktop` 图标
3. 按照安装向导的提示操作
4. 可能需要输入 macOS 管理员密码
5. 安装完成后，启动 Parallels Desktop

#### 2. 激活许可证

1. 启动 Parallels Desktop
2. 您可以选择：
   - 购买许可证
   - 输入已购买的许可证密钥
   - 开始 14 天免费试用

#### 3. 创建虚拟机

##### 安装 Windows 11

1. 点击 `文件` > `新建`
2. 选择 `从 DVD 或镜像文件安装 Windows 或其他操作系统`
3. Parallels Desktop 会自动下载 Windows 11（如果您使用的是 Apple Silicon Mac）
4. 或者选择本地的 Windows ISO 文件
5. 按照向导配置虚拟机：
   - 设置虚拟机名称
   - 选择主要用途（游戏、开发、仅办公等）
   - 分配 CPU 核心数和内存（推荐至少 4GB）
   - 选择硬盘大小（推荐至少 64GB）
6. 点击 `创建`，等待 Windows 安装完成

##### 安装 Linux（以 Ubuntu 为例）

1. 下载 Ubuntu ISO 文件：
   ```bash
   # 访问 https://ubuntu.com/download/desktop 下载最新版本
   # 对于 Apple Silicon Mac，选择 ARM64 版本
   # 对于 Intel Mac，选择 AMD64 版本
   ```

2. 在 Parallels Desktop 中创建虚拟机：
   - 点击 `文件` > `新建`
   - 选择 `从 DVD 或镜像文件安装`
   - 选择下载的 Ubuntu ISO 文件
   - 选择 `Linux` > `Ubuntu`
   - 配置虚拟机设置（名称、CPU、内存、硬盘）
   - 点击 `创建`

3. 完成 Ubuntu 安装向导

#### 4. 安装 Parallels Tools

安装完操作系统后，安装 Parallels Tools 以获得更好的性能和功能：

1. 在虚拟机运行时，点击 `操作` > `安装 Parallels Tools`
2. 在客户操作系统中运行安装程序
3. 安装完成后重启虚拟机

### 常用功能

#### Coherence 模式
在 Coherence 模式下，Windows 应用程序可以直接在 macOS 桌面上运行：

1. 点击 `视图` > `进入 Coherence 模式`
2. Windows 应用将出现在 macOS Dock 和应用程序切换器中

#### 共享文件夹
默认情况下，macOS 的主文件夹会自动共享到 Windows：
- 在 Windows 中访问 `\\psf\Home` 即可访问 Mac 文件

#### 快照功能
保存虚拟机的当前状态，以便随时恢复：

1. 点击 `操作` > `管理快照`
2. 点击 `拍摄新快照`
3. 输入快照名称和描述
4. 需要时可以恢复到该快照

### 性能优化

#### 调整资源分配

1. 关闭虚拟机
2. 右键点击虚拟机 > `配置`
3. 选择 `硬件` > `CPU 和内存`
4. 调整 CPU 核心数和内存大小
   - **建议**: 不要分配超过物理核心数的 50% 和物理内存的 50%

#### 启用硬件加速

1. 配置 > `硬件` > `图形`
2. 启用 `3D 加速`
3. 设置最大视频内存

---

## UTM 安装指南（Apple Silicon）

UTM 是一款免费开源的虚拟机软件，专为 Apple Silicon Mac 优化，使用苹果的虚拟化框架提供原生性能。

### 系统要求

- macOS 11.0 (Big Sur) 或更高版本
- Apple Silicon (M1/M2/M3) 或 Intel 处理器
- 至少 4GB RAM（推荐 8GB 或更多）
- 足够的磁盘空间用于虚拟机

### 安装步骤

#### 方法 1: 使用 Homebrew 安装（推荐）

```bash
# 安装 UTM
brew install --cask utm
```

#### 方法 2: 从 App Store 安装

1. 打开 App Store
2. 搜索 "UTM Virtual Machines"
3. 点击 `获取` 进行安装（付费版本，支持开发者，功能与免费版相同）

#### 方法 3: 从 GitHub 下载

1. 访问 [UTM GitHub Releases](https://github.com/utmapp/UTM/releases)
2. 下载最新的 `.dmg` 文件
3. 打开 `.dmg` 文件，将 UTM 拖到 `应用程序` 文件夹
4. 首次打开时，可能需要在 `系统设置` > `隐私与安全性` 中允许打开

### 创建虚拟机

#### 安装 Ubuntu Linux（ARM64）

Apple Silicon Mac 上推荐使用 ARM64 版本的 Linux 以获得最佳性能。

##### 1. 下载 Ubuntu ARM64 ISO

```bash
# 访问 Ubuntu 官网下载 ARM64 服务器版
# https://ubuntu.com/download/server/arm

# 或使用桌面版（推荐）
# https://cdimage.ubuntu.com/releases/22.04/release/
# 下载 ubuntu-22.04.x-desktop-arm64.iso
```

##### 2. 在 UTM 中创建虚拟机

1. 打开 UTM
2. 点击 `+` > `虚拟化`（使用苹果虚拟化，性能最佳）
3. 选择 `Linux`
4. 在 Boot ISO Image 中选择下载的 Ubuntu ISO 文件
5. 配置虚拟机：
   - **内存**: 至少 2048 MB（推荐 4096 MB 或更多）
   - **CPU 核心**: 2-4 个核心
   - **存储**: 至少 20 GB（推荐 64 GB）
6. 点击 `保存`
7. 点击虚拟机名称，然后点击播放按钮启动

##### 3. 完成 Ubuntu 安装

1. 虚拟机启动后，按照 Ubuntu 安装向导操作
2. 选择语言、键盘布局、时区等
3. 创建用户账户
4. 等待安装完成
5. 安装完成后，移除 ISO 镜像：
   - 点击虚拟机的 CD/DVD 图标
   - 选择 `Eject`
6. 重启虚拟机

##### 4. 安装 SPICE Guest Tools（推荐）

为了获得更好的性能和功能（如剪贴板共享、文件共享），安装 SPICE Guest Tools：

```bash
# 在 Ubuntu 虚拟机中运行
sudo apt update
sudo apt install spice-vdagent spice-webdavd
```

重启虚拟机后，即可使用剪贴板共享和文件共享功能。

#### 安装 Windows 11（ARM64）

Apple Silicon Mac 上可以运行 ARM64 版本的 Windows 11。

##### 1. 下载 Windows 11 ARM64 镜像

由于 Microsoft 不公开提供 Windows 11 ARM64 ISO，您需要：

1. 加入 [Windows Insider Program](https://insider.windows.com/)
2. 下载 Windows 11 ARM64 Insider Preview VHDX
3. 或者使用第三方工具如 [UUP dump](https://uupdump.net/) 创建 ISO

##### 2. 创建虚拟机

1. 打开 UTM，点击 `+` > `虚拟化`
2. 选择 `Windows`
3. 选择 `从 Windows Installer Boot ISO 导入`
4. 选择 Windows 11 ARM64 ISO 文件
5. 配置虚拟机：
   - **内存**: 至少 4096 MB（推荐 8192 MB）
   - **CPU 核心**: 4 个核心
   - **存储**: 至少 64 GB
6. 点击 `保存` 并启动虚拟机
7. 按照 Windows 11 安装向导完成安装

##### 3. 安装 SPICE Guest Tools

1. 在虚拟机运行时，下载 [SPICE Guest Tools for Windows](https://www.spice-space.org/download.html)
2. 运行安装程序
3. 重启虚拟机

> **注意**: 对于 ARM64 Windows，标准的 SPICE Guest Tools 应该能够工作。如果遇到问题，可以尝试使用 [virtio-win 驱动](https://github.com/virtio-win/virtio-win-pkg-scripts)。

#### 运行 x86 Linux/Windows（模拟模式）

如果您需要运行 x86/x64 架构的操作系统：

1. 创建虚拟机时选择 `模拟` 而不是 `虚拟化`
2. 选择 `x86_64` 架构
3. 其他步骤相同

> **注意**: 模拟模式性能较低，因为需要将 x86 指令转换为 ARM 指令。

### 高级配置

#### 共享文件夹

1. 关闭虚拟机
2. 右键点击虚拟机 > `编辑`
3. 点击 `驱动器` > `新建` > `共享目录`
4. 选择 macOS 上要共享的文件夹
5. 在 Linux 虚拟机中，使用以下命令挂载：

```bash
# 安装 davfs2
sudo apt install davfs2

# 创建挂载点
sudo mkdir /mnt/share

# 挂载共享文件夹（端口 9843 是 UTM 默认的 SPICE WebDAV 端口）
# 如果无法连接，请检查 UTM 网络设置中的端口配置
sudo mount -t davfs http://127.0.0.1:9843 /mnt/share
```

#### 调整分辨率

1. 右键点击虚拟机 > `编辑`
2. 选择 `显示`
3. 调整 `分辨率` 设置

#### 网络配置

默认情况下，UTM 使用 `共享网络` 模式，虚拟机可以访问互联网但外部无法访问虚拟机。

如需配置端口转发或桥接网络：

1. 右键点击虚拟机 > `编辑`
2. 选择 `网络`
3. 配置网络模式和端口转发规则

### 性能优化技巧

1. **使用虚拟化而非模拟**: 始终选择与您的 Mac 架构匹配的操作系统（ARM64）
2. **分配足够的资源**: 但不要超过物理资源的 50-60%
3. **启用 SPICE 工具**: 可显著提升性能和用户体验
4. **使用轻量级桌面环境**: 如 Xfce 或 LXDE，而不是 GNOME
5. **关闭不必要的服务**: 减少虚拟机内的后台进程

---

## 常见问题

### 1. Apple Silicon Mac 可以运行 Windows 10 吗？

**答**: 不能运行 x86/x64 版本的 Windows 10。对于 Apple Silicon Mac，推荐使用 ARM64 版本的 Windows 11（通过 Parallels Desktop 或 UTM）。虽然 Windows 10 ARM64 版本存在，但不推荐使用，因为它主要面向 OEM 厂商，不易获取且兼容性不如 Windows 11。如果必须运行 x86/x64 版本的 Windows 10，只能通过性能较低的模拟模式。

### 2. 虚拟机性能如何？

- **Parallels Desktop**: 性能最佳，接近原生性能，特别是在 Apple Silicon Mac 上运行 ARM64 Windows
- **UTM (虚拟化模式)**: 性能良好，适合日常使用
- **UTM (模拟模式)**: 性能较低，仅适合测试和开发
- **VirtualBox**: 在 Intel Mac 上性能中等

### 3. 我应该分配多少内存和 CPU 给虚拟机？

**推荐配置**:
- **内存**: 物理内存的 25-50%（至少 4GB）
- **CPU**: 物理核心数的 25-50%（至少 2 核）

例如：如果您的 Mac 有 16GB 内存和 8 核 CPU，可以分配 4-8GB 内存和 2-4 核 CPU 给虚拟机。

### 4. 虚拟机可以访问 macOS 文件吗？

**答**: 可以。所有主流虚拟机软件都支持文件共享功能：
- **Parallels Desktop**: 默认共享 Mac 主文件夹
- **UTM**: 需要手动配置共享文件夹（使用 WebDAV）
- **VMware Fusion**: 支持共享文件夹
- **VirtualBox**: 支持共享文件夹

### 5. 虚拟机会影响 Mac 性能吗？

**答**: 会占用系统资源，但只在虚拟机运行时。建议：
- 不使用时关闭或暂停虚拟机
- 不要同时运行多个虚拟机
- 合理分配资源，不要超过物理资源的 50%

### 6. 免费方案够用吗？

**答**: 
- **个人用户、学习使用**: UTM 或 VMware Fusion Personal 完全够用
- **专业用户、需要最佳性能**: 建议购买 Parallels Desktop
- **企业用户**: 建议使用 VMware Fusion 或 Parallels Business Edition

### 7. 如何在虚拟机之间迁移？

- **Parallels Desktop** 和 **VMware Fusion** 支持导入对方的虚拟机格式
- **UTM** 可以导入 QEMU 格式的虚拟机
- 通常需要重新安装 Guest Tools/Additions

### 8. 虚拟机可以使用 GPU 吗？

- **Parallels Desktop**: 支持 GPU 虚拟化，可运行一些图形应用和轻度游戏
- **UTM**: 支持基本的显卡虚拟化，但性能有限
- **VMware Fusion**: 支持 3D 图形加速

> **注意**: 虚拟机的 GPU 性能远不如原生系统，不适合运行高性能图形应用或大型游戏。

---

## 总结

根据您的需求选择合适的虚拟机方案：

| 方案 | 适用场景 | 优势 | 成本 |
|------|---------|------|------|
| **Parallels Desktop** | 专业用户，需要最佳性能 | 性能最优，功能最全，易用 | $99.99/年 |
| **VMware Fusion** | 企业用户，VMware 生态 | 企业级功能，个人免费 | 个人免费 |
| **UTM** | Apple Silicon 用户，开源爱好者 | 免费开源，原生 ARM 支持 | 免费 |
| **VirtualBox** | Intel Mac 用户，预算有限 | 完全免费，跨平台 | 免费 |

**我们的推荐**:
- **Apple Silicon Mac**: UTM（免费）或 Parallels Desktop（付费，性能更好）
- **Intel Mac**: VMware Fusion Personal（免费）或 VirtualBox（免费）

---

## 参考资料

- [Parallels Desktop 官网](https://www.parallels.com/)
- [VMware Fusion 官网](https://www.vmware.com/products/fusion.html)
- [UTM 官网](https://mac.getutm.app/)
- [UTM GitHub](https://github.com/utmapp/UTM)
- [VirtualBox 官网](https://www.virtualbox.org/)
- [QEMU 官网](https://www.qemu.org/)
- [Apple 虚拟化框架文档](https://developer.apple.com/documentation/virtualization)
