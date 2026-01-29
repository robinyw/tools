# NPM/Node.js 项目安装部署指南

## 环境要求

- Node.js >= 14.0.0
- npm >= 6.0.0 或 yarn >= 1.22.0

## 安装步骤

### 1. 安装 Node.js 和 npm

#### Windows
从 [Node.js 官网](https://nodejs.org/) 下载并安装最新 LTS 版本。

#### macOS
```bash
# 使用 Homebrew
brew install node

# 或者从官网下载
https://nodejs.org/
```

#### Linux (Ubuntu/Debian)
```bash
# 使用 apt
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs

# 验证安装
node --version
npm --version
```

### 2. 初始化项目

```bash
# 创建新项目
mkdir my-project
cd my-project
npm init -y

# 或克隆现有项目
git clone <repository-url>
cd <project-directory>
```

### 3. 安装依赖

```bash
# 安装所有依赖
npm install

# 或使用 yarn
yarn install

# 安装开发依赖
npm install --save-dev <package-name>

# 安装生产依赖
npm install --save <package-name>
```

## 开发环境配置

### 环境变量

创建 `.env` 文件（不要提交到版本控制）：

```bash
NODE_ENV=development
PORT=3000
API_URL=http://localhost:3000
```

### 启动开发服务器

```bash
# 使用 npm scripts
npm run dev

# 或直接运行
node index.js

# 使用 nodemon 自动重启
npm install -g nodemon
nodemon index.js
```

## 构建和部署

### 构建生产版本

```bash
# 构建项目
npm run build

# 运行测试
npm test

# 检查代码质量
npm run lint
```

### 部署到生产环境

#### 1. 准备部署

```bash
# 设置生产环境变量
export NODE_ENV=production

# 安装仅生产依赖
npm install --production
```

#### 2. 使用 PM2 进行进程管理

```bash
# 安装 PM2
npm install -g pm2

# 启动应用
pm2 start index.js --name my-app

# 查看状态
pm2 status

# 查看日志
pm2 logs

# 重启应用
pm2 restart my-app

# 开机自启动
pm2 startup
pm2 save
```

#### 3. 使用 Docker 部署

创建 `Dockerfile`：

```dockerfile
FROM node:20-alpine

WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

COPY . .

EXPOSE 3000

CMD ["node", "index.js"]
```

构建和运行：

```bash
# 构建镜像
docker build -t my-app .

# 运行容器
docker run -d -p 3000:3000 --name my-app my-app
```

## 常见问题

### 依赖安装失败

```bash
# 清除缓存
npm cache clean --force

# 删除 node_modules 和 package-lock.json
rm -rf node_modules package-lock.json

# 重新安装
npm install
```

### 端口被占用

```bash
# 查找占用端口的进程
lsof -i :3000

# 或在 Windows
netstat -ano | findstr :3000

# 结束进程
kill -9 <PID>
```

## 最佳实践

1. 使用 `.nvmrc` 文件指定 Node.js 版本
2. 使用 `package-lock.json` 锁定依赖版本
3. 配置 `.gitignore` 忽略 `node_modules` 和 `.env`
4. 使用环境变量管理配置
5. 定期更新依赖包以修复安全漏洞
6. 使用 ESLint 和 Prettier 保持代码质量

## 相关资源

- [Node.js 官方文档](https://nodejs.org/docs/)
- [npm 官方文档](https://docs.npmjs.com/)
- [PM2 文档](https://pm2.keymetrics.io/)
- [Docker 文档](https://docs.docker.com/)
