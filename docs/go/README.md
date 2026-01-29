# Go 项目安装部署指南

## 环境要求

- Go >= 1.19

## 安装步骤

### 1. 安装 Go

#### Windows
从 [Go 官网](https://golang.org/dl/) 下载并安装 MSI 安装包。

#### macOS
```bash
# 使用 Homebrew
brew install go

# 或从官网下载
https://golang.org/dl/
```

#### Linux
```bash
# 下载并安装
wget https://go.dev/dl/go1.21.5.linux-amd64.tar.gz
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf go1.21.5.linux-amd64.tar.gz

# 配置环境变量
echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
echo 'export GOPATH=$HOME/go' >> ~/.bashrc
echo 'export PATH=$PATH:$GOPATH/bin' >> ~/.bashrc
source ~/.bashrc

# 验证安装
go version
```

### 2. 配置 Go 环境

```bash
# 查看 Go 环境变量
go env

# 设置 GOPROXY（加速依赖下载）
go env -w GOPROXY=https://goproxy.cn,direct

# 设置 GOPRIVATE（私有仓库）
go env -w GOPRIVATE=github.com/mycompany/*

# 启用 Go Modules
go env -w GO111MODULE=on
```

### 3. 创建项目

```bash
# 创建项目目录
mkdir my-project
cd my-project

# 初始化 Go Module
go mod init github.com/username/my-project

# 创建 main.go
cat > main.go << 'EOF'
package main

import "fmt"

func main() {
    fmt.Println("Hello, World!")
}
EOF

# 运行程序
go run main.go
```

### 4. 管理依赖

```bash
# 添加依赖
go get github.com/gin-gonic/gin

# 查看依赖
go list -m all

# 更新依赖
go get -u github.com/gin-gonic/gin

# 更新所有依赖
go get -u ./...

# 清理未使用的依赖
go mod tidy

# 下载依赖到本地缓存
go mod download

# 将依赖复制到 vendor 目录
go mod vendor
```

## 开发环境配置

### IDE 配置

#### VS Code
```bash
# 安装 Go 扩展
code --install-extension golang.go

# 安装 Go 工具
go install golang.org/x/tools/gopls@latest
go install github.com/go-delve/delve/cmd/dlv@latest
```

#### GoLand
从 [JetBrains](https://www.jetbrains.com/go/) 下载并安装。

### 项目结构

推荐的项目结构：

```
my-project/
├── cmd/                    # 应用程序入口
│   └── myapp/
│       └── main.go
├── internal/              # 私有应用代码
│   ├── handler/
│   ├── service/
│   └── repository/
├── pkg/                   # 公共库代码
│   └── utils/
├── api/                   # API 定义（如 OpenAPI/Swagger）
├── configs/               # 配置文件
├── scripts/               # 脚本
├── test/                  # 测试文件
├── go.mod
├── go.sum
├── Makefile
└── README.md
```

### 配置文件管理

使用 Viper 管理配置：

```bash
go get github.com/spf13/viper
```

示例代码：

```go
package config

import (
    "github.com/spf13/viper"
)

type Config struct {
    Server ServerConfig
    Database DatabaseConfig
}

type ServerConfig struct {
    Port string
    Mode string
}

type DatabaseConfig struct {
    Host     string
    Port     int
    Username string
    Password string
    DBName   string
}

func LoadConfig(path string) (*Config, error) {
    viper.SetConfigFile(path)
    viper.AutomaticEnv()
    
    if err := viper.ReadInConfig(); err != nil {
        return nil, err
    }
    
    var config Config
    if err := viper.Unmarshal(&config); err != nil {
        return nil, err
    }
    
    return &config, nil
}
```

`config.yaml`:

```yaml
server:
  port: "8080"
  mode: "development"

database:
  host: "localhost"
  port: 5432
  username: "postgres"
  password: "password"
  dbname: "mydb"
```

### 环境变量

使用 godotenv：

```bash
go get github.com/joho/godotenv
```

`.env`:

```bash
APP_ENV=development
APP_PORT=8080
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=password
DB_NAME=mydb
```

加载环境变量：

```go
import "github.com/joho/godotenv"

func init() {
    if err := godotenv.Load(); err != nil {
        log.Println("No .env file found")
    }
}
```

## 构建和测试

### 构建应用

```bash
# 构建当前平台
go build -o myapp main.go

# 交叉编译 Linux
GOOS=linux GOARCH=amd64 go build -o myapp-linux main.go

# 交叉编译 Windows
GOOS=windows GOARCH=amd64 go build -o myapp.exe main.go

# 交叉编译 macOS
GOOS=darwin GOARCH=amd64 go build -o myapp-mac main.go

# 减小二进制文件大小
go build -ldflags="-s -w" -o myapp main.go

# 使用 UPX 进一步压缩
upx --best --lzma myapp
```

### 运行测试

```bash
# 运行所有测试
go test ./...

# 运行带详细输出的测试
go test -v ./...

# 运行特定包的测试
go test -v ./internal/service

# 运行特定测试函数
go test -v -run TestFunctionName

# 生成覆盖率报告
go test -coverprofile=coverage.out ./...
go tool cover -html=coverage.out -o coverage.html

# 基准测试
go test -bench=. -benchmem ./...
```

### 代码质量

```bash
# 格式化代码
go fmt ./...
gofmt -s -w .

# 使用 goimports（自动处理导入）
go install golang.org/x/tools/cmd/goimports@latest
goimports -w .

# 代码检查
go vet ./...

# 使用 golangci-lint
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
golangci-lint run

# 静态分析
go install honnef.co/go/tools/cmd/staticcheck@latest
staticcheck ./...
```

### Makefile 示例

创建 `Makefile`:

```makefile
.PHONY: build run test clean lint

APP_NAME=myapp
BUILD_DIR=build

build:
	go build -o $(BUILD_DIR)/$(APP_NAME) cmd/myapp/main.go

run:
	go run cmd/myapp/main.go

test:
	go test -v ./...

test-coverage:
	go test -coverprofile=coverage.out ./...
	go tool cover -html=coverage.out

lint:
	golangci-lint run

fmt:
	go fmt ./...
	goimports -w .

clean:
	rm -rf $(BUILD_DIR)
	go clean

deps:
	go mod download
	go mod tidy

install:
	go install ./cmd/myapp
```

## 常用框架

### Web 框架 - Gin

```bash
go get -u github.com/gin-gonic/gin
```

示例：

```go
package main

import (
    "github.com/gin-gonic/gin"
    "net/http"
)

func main() {
    r := gin.Default()
    
    r.GET("/ping", func(c *gin.Context) {
        c.JSON(http.StatusOK, gin.H{
            "message": "pong",
        })
    })
    
    r.Run(":8080")
}
```

### ORM - GORM

```bash
go get -u gorm.io/gorm
go get -u gorm.io/driver/postgres
```

示例：

```go
import (
    "gorm.io/driver/postgres"
    "gorm.io/gorm"
)

type User struct {
    ID   uint
    Name string
}

func main() {
    dsn := "host=localhost user=postgres password=password dbname=mydb port=5432"
    db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
    if err != nil {
        panic(err)
    }
    
    // 自动迁移
    db.AutoMigrate(&User{})
    
    // 创建
    db.Create(&User{Name: "John"})
    
    // 查询
    var user User
    db.First(&user, 1)
}
```

## 部署到生产环境

### 1. 构建生产版本

```bash
# 构建静态链接的二进制文件
CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o myapp main.go

# 或使用 ldflags 添加版本信息
go build -ldflags="-X main.Version=1.0.0 -X main.BuildTime=$(date +%Y%m%d%H%M%S)" -o myapp
```

### 2. 使用 Systemd

创建服务文件 `/etc/systemd/system/myapp.service`:

```ini
[Unit]
Description=My Go Application
After=network.target

[Service]
Type=simple
User=appuser
WorkingDirectory=/opt/myapp
ExecStart=/opt/myapp/myapp
Restart=on-failure
RestartSec=10s
Environment="APP_ENV=production"

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

### 3. 使用 Docker 部署

创建 `Dockerfile`:

```dockerfile
FROM golang:1.21-alpine AS builder

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o myapp cmd/myapp/main.go

FROM alpine:latest

RUN apk --no-cache add ca-certificates

WORKDIR /root/

COPY --from=builder /app/myapp .
COPY --from=builder /app/configs ./configs

EXPOSE 8080

CMD ["./myapp"]
```

使用 scratch 基础镜像（最小化）：

```dockerfile
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -a -ldflags="-s -w" -o myapp cmd/myapp/main.go

FROM scratch
COPY --from=builder /app/myapp /myapp
COPY --from=builder /app/configs /configs
EXPOSE 8080
ENTRYPOINT ["/myapp"]
```

构建和运行：

```bash
# 构建镜像
docker build -t myapp:latest .

# 运行容器
docker run -d -p 8080:8080 --name myapp myapp:latest

# 使用 docker-compose
```

`docker-compose.yml`:

```yaml
version: '3.8'

services:
  app:
    build: .
    ports:
      - "8080:8080"
    environment:
      - APP_ENV=production
      - DB_HOST=db
    depends_on:
      - db
    restart: unless-stopped
  
  db:
    image: postgres:15-alpine
    environment:
      - POSTGRES_DB=mydb
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=password
    volumes:
      - postgres_data:/var/lib/postgresql/data
    restart: unless-stopped

volumes:
  postgres_data:
```

### 4. Kubernetes 部署

创建 `k8s/deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: myapp
spec:
  replicas: 3
  selector:
    matchLabels:
      app: myapp
  template:
    metadata:
      labels:
        app: myapp
    spec:
      containers:
      - name: myapp
        image: myapp:latest
        ports:
        - containerPort: 8080
        env:
        - name: APP_ENV
          value: "production"
        resources:
          requests:
            memory: "64Mi"
            cpu: "250m"
          limits:
            memory: "128Mi"
            cpu: "500m"
---
apiVersion: v1
kind: Service
metadata:
  name: myapp-service
spec:
  selector:
    app: myapp
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8080
  type: LoadBalancer
```

部署：

```bash
kubectl apply -f k8s/
kubectl get pods
kubectl get svc
```

## 监控和日志

### 结构化日志 - Zap

```bash
go get -u go.uber.org/zap
```

示例：

```go
import "go.uber.org/zap"

logger, _ := zap.NewProduction()
defer logger.Sync()

logger.Info("Server started",
    zap.String("port", "8080"),
    zap.String("env", "production"),
)
```

### Prometheus 监控

```bash
go get github.com/prometheus/client_golang/prometheus
go get github.com/prometheus/client_golang/prometheus/promhttp
```

示例：

```go
import (
    "github.com/prometheus/client_golang/prometheus"
    "github.com/prometheus/client_golang/prometheus/promhttp"
)

var (
    httpRequests = prometheus.NewCounterVec(
        prometheus.CounterOpts{
            Name: "http_requests_total",
            Help: "Total number of HTTP requests",
        },
        []string{"method", "endpoint"},
    )
)

func init() {
    prometheus.MustRegister(httpRequests)
}

func main() {
    http.Handle("/metrics", promhttp.Handler())
    http.ListenAndServe(":8080", nil)
}
```

## 常见问题

### 依赖下载慢

```bash
# 使用国内镜像
go env -w GOPROXY=https://goproxy.cn,direct
go env -w GOPROXY=https://goproxy.io,direct
```

### 导入私有仓库

```bash
# 设置 GOPRIVATE
go env -w GOPRIVATE=github.com/mycompany/*

# 配置 Git 认证
git config --global url."git@github.com:".insteadOf "https://github.com/"
```

### 内存泄漏

```bash
# 使用 pprof 分析
import _ "net/http/pprof"

http.ListenAndServe(":6060", nil)

# 访问 http://localhost:6060/debug/pprof/
# 生成堆分析
go tool pprof http://localhost:6060/debug/pprof/heap
```

## 最佳实践

1. 始终使用 Go Modules 管理依赖
2. 遵循标准项目结构
3. 使用 context 管理超时和取消
4. 使用 errgroup 管理并发错误
5. 避免全局变量，使用依赖注入
6. 编写单元测试和基准测试
7. 使用结构化日志
8. 实施优雅关闭（graceful shutdown）
9. 使用 Makefile 简化构建流程
10. 定期更新依赖以修复安全漏洞

## 相关资源

- [Go 官方文档](https://golang.org/doc/)
- [Go by Example](https://gobyexample.com/)
- [Effective Go](https://golang.org/doc/effective_go)
- [Gin 文档](https://gin-gonic.com/docs/)
- [GORM 文档](https://gorm.io/docs/)
- [Go 标准库](https://pkg.go.dev/std)
