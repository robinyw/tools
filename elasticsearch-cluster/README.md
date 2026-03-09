# Elasticsearch 8.17.0 高可用集群部署方案

## 集群架构

```
                    ┌─────────────────────────────────────────┐
                    │              客户端 / Kibana              │
                    └──────────────┬──────────────────────────┘
                                   │ HTTPS 9200/9201/5601
          ┌────────────────────────┴─────────────────────────────┐
          │                                                       │
┌─────────▼───────────────────┐           ┌──────────────────────▼───────────┐
│         ECS-1                │           │         ECS-2                     │
│     172.16.0.20              │           │     172.16.0.21                   │
│                              │           │                                   │
│  ┌───────────────────────┐   │           │  ┌──────────────────────────┐    │
│  │ es-node1 (Master)     │   │◄─────────►│  │ es-node3 (Master+Data)   │    │
│  │ port: 9200/9300       │   │  9300/9301│  │ port: 9200/9300          │    │
│  │ heap: 2g              │   │           │  │ heap: 6g                  │    │
│  └───────────────────────┘   │           │  └──────────────────────────┘    │
│                              │           │                                   │
│  ┌───────────────────────┐   │           │  ┌──────────────────────────┐    │
│  │ es-node2 (Data+Ingest)│   │           │  │ kibana                   │    │
│  │ port: 9201/9301       │   │           │  │ port: 5601               │    │
│  │ heap: 5g              │   │           │  │ heap: 2g                  │    │
│  └───────────────────────┘   │           │  └──────────────────────────┘    │
└──────────────────────────────┘           └──────────────────────────────────┘
           Transport: 9300/9301 ←──────────────────────────────────────────────
```

---

## 硬件配置

| 服务器 | 规格 | 用途 |
|--------|------|------|
| ECS-1  | 4c16g | es-node1（纯 Master）+ es-node2（Data+Ingest） |
| ECS-2  | 4c16g | es-node3（Master+Data+Ingest）+ Kibana |

---

## 内存规划

| 容器 | JVM 堆内存 | 说明 |
|------|-----------|------|
| es-node1 | 2g | 纯 Master，无数据压力 |
| es-node2 | 5g | 数据节点，承载写入/查询 |
| es-node3 | 6g | Master+Data，主力数据节点 |
| kibana | 2g | Node.js 进程内存上限 |
| 系统预留 | ≥1g | 各机器 OS 及其他进程 |

**ECS-1 内存合计**：2g + 5g = 7g（16g 剩余 9g 供 OS）  
**ECS-2 内存合计**：6g + 2g = 8g（16g 剩余 8g 供 OS）

---

## 节点规划

| 服务器 | IP | 容器 | 角色 | 堆内存 | 端口 |
|--------|-----|------|------|--------|------|
| ECS-1 | 172.16.0.20 | es-node1 | 纯 master | 2g | 9200/9300 |
| ECS-1 | 172.16.0.20 | es-node2 | 纯 data+ingest | 5g | 9201/9301 |
| ECS-2 | 172.16.0.21 | es-node3 | master+data+ingest | 6g | 9200/9300 |
| ECS-2 | 172.16.0.21 | kibana | - | 2g | 5601 |

**master 候选节点**：es-node1 + es-node3（共 2 个，避免脑裂需要奇数，生产建议 3 个）

---

## 目录结构

```
elasticsearch-cluster/
├── README.md                   # 本文档
├── 00-generate-certs.sh        # TLS 证书生成脚本（在 ECS-1 执行）
├── 01-init-ecs1.sh             # ECS-1 系统初始化脚本
├── 01-init-ecs2.sh             # ECS-2 系统初始化脚本
├── 02-setup-passwords.sh       # ES 密码初始化脚本（集群启动后执行）
├── 03-deploy-guide.sh          # 完整部署流程指引
├── ecs1/
│   └── docker-compose.yml      # ECS-1 的 docker-compose 配置
└── ecs2/
    ├── docker-compose.yml      # ECS-2 的 docker-compose 配置
    └── .env.example            # 环境变量模板（需复制为 .env 并填写密码）

/data/elasticsearch/            # 运行时数据目录（部署时创建）
├── certs/                      # TLS 证书（所有节点共享）
│   ├── ca/
│   │   ├── ca.crt
│   │   └── ca.key
│   ├── es-node1/
│   ├── es-node2/
│   ├── es-node3/
│   └── kibana/
├── node1/data, node1/logs      # es-node1 数据和日志
├── node2/data, node2/logs      # es-node2 数据和日志
├── node3/data, node3/logs      # es-node3 数据和日志
└── kibana/data                 # Kibana 数据
```

---

## 前提条件

- Docker >= 20.10、Docker Compose >= 2.0（两台服务器均需安装）
- 防火墙规则：
  - ECS-1 ↔ ECS-2 双向开放 TCP **9300**、**9301**（ES transport 通信）
  - 外部访问 ECS-1 开放 **9200**、**9201**
  - 外部访问 ECS-2 开放 **9200**、**5601**
- 两台 ECS 之间网络互通，且可用 rsync/scp 传输文件
- 本项目中的 shell 脚本需在 root 用户或具有 sudo 权限的用户下执行

---

## 完整部署步骤

### Step 1：ECS-1 系统初始化

在 ECS-1（172.16.0.20）上执行：

```bash
bash 01-init-ecs1.sh
```

- 创建数据目录 `/data/elasticsearch/node1`、`/data/elasticsearch/node2`
- 设置 `vm.max_map_count=262144`（ES 必需）
- 设置 `nofile` 和 `nproc` 资源限制

### Step 2：ECS-1 生成 TLS 证书

在 ECS-1（172.16.0.20）上执行：

```bash
bash 00-generate-certs.sh
```

- 调用官方 ES 镜像内置工具生成 CA 证书和各节点证书
- 证书存放于 `/data/elasticsearch/certs/`

### Step 3：同步证书到 ECS-2

在 ECS-1 上执行：

```bash
rsync -avz /data/elasticsearch/certs/ \
  root@172.16.0.21:/data/elasticsearch/certs/
```

### Step 4：ECS-2 系统初始化

在 ECS-2（172.16.0.21）上执行：

```bash
bash 01-init-ecs2.sh
```

- 创建数据目录 `/data/elasticsearch/node3`、`/data/elasticsearch/kibana`
- 设置 `vm.max_map_count=262144`
- 设置资源限制

### Step 5：ECS-1 启动 ES 节点

在 ECS-1 上执行：

```bash
cp -r ecs1 /data/elasticsearch/ecs1
cd /data/elasticsearch/ecs1
docker-compose up -d
```

观察日志确认两个节点启动正常：

```bash
docker logs -f es-node1
docker logs -f es-node2
```

### Step 6：ECS-2 启动 ES 节点（先不启动 Kibana）

在 ECS-2（172.16.0.21）上执行：

```bash
cp -r ecs2 /data/elasticsearch/ecs2
cd /data/elasticsearch/ecs2
docker-compose up -d es-node3
```

### Step 7：ECS-1 初始化密码

等待集群三个节点全部就绪后，在 ECS-1 执行：

```bash
bash 02-setup-passwords.sh
```

密码将保存到 `/data/elasticsearch/passwords.txt`，**请立即记录 kibana_system 密码**。

### Step 8：ECS-2 填入 kibana_system 密码

在 ECS-2 执行：

```bash
cp /data/elasticsearch/ecs2/.env.example /data/elasticsearch/ecs2/.env
vi /data/elasticsearch/ecs2/.env
# 将 KIBANA_PASSWORD 替换为实际密码
```

### Step 9：ECS-2 启动 Kibana

在 ECS-2 执行：

```bash
cd /data/elasticsearch/ecs2
docker-compose up -d kibana
```

访问 Kibana：**https://172.16.0.21:5601**（使用 elastic 账户登录）

---

## 验证命令

```bash
# 查看集群健康状态
curl -s --cacert /data/elasticsearch/certs/ca/ca.crt \
  -u elastic:<your_password> \
  https://172.16.0.20:9200/_cluster/health?pretty

# 查看节点列表
curl -s --cacert /data/elasticsearch/certs/ca/ca.crt \
  -u elastic:<your_password> \
  https://172.16.0.20:9200/_cat/nodes?v

# 查看分片分配
curl -s --cacert /data/elasticsearch/certs/ca/ca.crt \
  -u elastic:<your_password> \
  https://172.16.0.20:9200/_cat/shards?v

# 查看集群节点角色
curl -s --cacert /data/elasticsearch/certs/ca/ca.crt \
  -u elastic:<your_password> \
  https://172.16.0.20:9200/_cat/nodes?v&h=name,ip,roles,heapPercent,ramPercent,cpu,load_1m
```

---

## 索引分片最佳实践

- **主分片数**：建议设为 2（等于 data 节点数：es-node2 和 es-node3）
- **副本数**：建议设为 1，确保高可用
- **单分片大小**：建议控制在 10~50 GB 以内

创建索引示例：

```json
PUT /my-index
{
  "settings": {
    "number_of_shards": 2,
    "number_of_replicas": 1
  }
}
```

---

## 扩容说明

### 水平扩容（新增 Data 节点）

1. 在新服务器运行 `01-init-ecs*.sh` 初始化系统
2. 同步 TLS 证书到新服务器
3. 编写新节点的 `docker-compose.yml`（`node.roles=data,ingest`）
4. 启动新节点，它会自动加入集群并接收分片迁移
5. 分片会自动再平衡，无需手动干预

### 垂直扩容（增加节点内存）

1. 修改 `docker-compose.yml` 中的 `ES_JAVA_OPTS=-Xms{size}g -Xmx{size}g`
2. 重启对应容器：`docker-compose up -d --force-recreate es-nodeX`

---

## 注意事项

1. **安全**：`passwords.txt` 包含明文密码，查看后务必删除：`rm -f /data/elasticsearch/passwords.txt`
2. **脑裂**：当前 master 候选节点仅 2 个，`cluster.initial_master_nodes` 仅用于首次引导集群，生产环境建议 3 个 master 候选节点
3. **证书有效期**：默认证书有效期 3 年，需提前规划续期
4. **时间同步**：各节点服务器时间必须同步，建议使用 NTP 服务
5. **备份**：定期备份 `/data/elasticsearch/` 数据目录，生产环境建议配置 snapshot repository
6. **监控**：建议在 Kibana 中启用 Stack Monitoring 监控集群健康指标
7. **升级**：升级 ES 版本前必须备份数据，并按照官方滚动升级指南操作
