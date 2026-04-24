# Spark + HDFS + YARN HA Docker Compose 生产级部署文档

## 目录

1. [架构概述](#架构概述)
2. [节点角色分配](#节点角色分配)
3. [软件版本](#软件版本)
4. [前提条件](#前提条件)
5. [目录结构](#目录结构)
6. [部署步骤](#部署步骤)
7. [启动顺序](#启动顺序)
8. [验证集群状态](#验证集群状态)
9. [Web UI 访问地址](#web-ui-访问地址)
10. [扩容 Worker 节点](#扩容-worker-节点)
11. [常见问题排查（FAQ）](#常见问题排查faq)
12. [生产运维建议](#生产运维建议)

---

## 架构概述

本方案采用 **HDFS HA + YARN HA + ZooKeeper Quorum** 架构，基于 Docker Compose 部署在 3 台物理/云服务器上，支持自动故障转移，适用于生产环境。

```
┌─────────────────────────────────────────────────────────────────┐
│                        客户端 / Spark 应用                       │
└──────────────────────────┬──────────────────────────────────────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
        ▼                  ▼                  ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────────┐
│  spark-master│  │ spark-worker1│  │  hadoop-node3    │
│  192.168.1.10│  │ 192.168.1.11 │  │  192.168.1.12    │
│  4C 16G 200G │  │  8C 32G 500G │  │  4C 16G 200G     │
├──────────────┤  ├──────────────┤  ├──────────────────┤
│NameNode(A)   │  │ DataNode     │  │ NameNode(S)      │
│ ResourceMgr  │  │ NodeManager  │  │ ResourceMgr(S)   │
│ ZooKeeper    │  │ ZooKeeper    │  │ ZooKeeper        │
│ JournalNode  │  │ JournalNode  │  │ JournalNode      │
│ ZKFC         │  │              │  │ ZKFC             │
│ HistoryServer│  │              │  │ DataNode         │
└──────────────┘  └──────────────┘  │ NodeManager      │
                                    └──────────────────┘

HDFS HA:
  Active NameNode ◄─── JournalNode Quorum ───► Standby NameNode
  Active NameNode ◄─── ZooKeeper (ZKFC) ─────► Standby NameNode

YARN HA:
  Active ResourceManager ◄─── ZooKeeper ───► Standby ResourceManager
```

**关键特性：**
- **HDFS HA**：通过 JournalNode 同步 EditLog，ZKFC 监控并触发自动故障转移
- **YARN HA**：Active/Standby ResourceManager 通过 ZooKeeper 实现高可用
- **ZooKeeper Quorum**：3 节点奇数集群，容忍 1 台故障
- **Docker Compose**：每台机器独立编排，network_mode=host 保证网络性能

---

## 节点角色分配

| 节点 | IP | 配置 | 磁盘 | 服务角色 |
|------|----|------|------|---------|
| spark-master | 192.168.1.10 | 4C 16G | 200G | NameNode(Active), ResourceManager(Active), ZooKeeper(1), JournalNode, ZKFC, Spark HistoryServer |
| spark-worker1 | 192.168.1.11 | 8C 32G | 500G | DataNode, NodeManager, ZooKeeper(2), JournalNode |
| hadoop-node3 | 192.168.1.12 | 4C 16G | 200G | NameNode(Standby), ResourceManager(Standby), ZooKeeper(3), JournalNode, ZKFC, DataNode, NodeManager |

---

## 软件版本

| 组件 | 版本 | 说明 |
|------|------|------|
| Ubuntu | 22.04 LTS | 宿主机操作系统 |
| Docker | 24.0+ | 容器运行时 |
| Docker Compose | 2.20+ | 容器编排工具 |
| JDK | OpenJDK 11 | Java 运行环境 |
| Hadoop | 3.3.6 | HDFS + YARN |
| Spark | 3.5.1 | 计算引擎 |
| ZooKeeper | 3.8.4 | 分布式协调服务 |

---

## 前提条件

### 1. 网络要求

- 三台节点**内网互通**，延迟 < 1ms（建议同机房/同 VPC）
- 以下端口在内网开放：

| 端口 | 服务 | 说明 |
|------|------|------|
| 2181 | ZooKeeper | 客户端连接端口 |
| 2888 | ZooKeeper | Follower 连接 Leader |
| 3888 | ZooKeeper | Leader 选举 |
| 8020 | HDFS NameNode | RPC 端口 |
| 9870 | HDFS NameNode | Web UI |
| 8485 | JournalNode | EditLog 同步 |
| 8088 | YARN ResourceManager | Web UI / REST API |
| 18080 | Spark HistoryServer | Web UI |
| 10020 | MapReduce HistoryServer | RPC |
| 19888 | MapReduce HistoryServer | Web UI |

### 2. 主机名解析

在所有节点的 `/etc/hosts` 中添加：

```
192.168.1.10  spark-master
192.168.1.11  spark-worker1
192.168.1.12  hadoop-node3
```

### 3. 软件依赖

每台节点安装：
```bash
# Docker Engine
curl -fsSL https://get.docker.com | sh

# Docker Compose Plugin
apt install -y docker-compose-plugin

# 基础工具
apt install -y rsync openssh-server
```

### 4. SSH 免密登录

在 spark-master 上配置到所有节点的 SSH 免密登录（add-worker.sh 需要）：

```bash
ssh-keygen -t rsa -b 4096 -N '' -f ~/.ssh/id_rsa
ssh-copy-id root@spark-worker1
ssh-copy-id root@hadoop-node3
```

---

## 目录结构

```
spark/
├── README.md                          # 本部署文档
├── .env                               # 环境变量配置
├── Dockerfile                         # 自定义镜像（可选）
├── docker-compose-master.yml          # spark-master 节点编排
├── docker-compose-worker1.yml         # spark-worker1 节点编排
├── docker-compose-node3.yml           # hadoop-node3 节点编排
├── config/
│   ├── hadoop/
│   │   ├── core-site.xml              # HDFS 核心配置（HA 模式）
│   │   ├── hdfs-site.xml              # HDFS 站点配置
│   │   ├── yarn-site.xml              # YARN 配置
│   │   ├── mapred-site.xml            # MapReduce 配置
│   │   └── workers                    # DataNode/NodeManager 节点列表
│   ├── spark/
│   │   ├── spark-defaults.conf        # Spark 默认配置
│   │   └── spark-env.sh               # Spark 环境变量
│   └── zookeeper/
│       └── zoo.cfg                    # ZooKeeper 配置
└── scripts/
    ├── init.sh                        # 初始化脚本（首次部署）
    ├── start-all.sh                   # 启动所有服务
    ├── stop-all.sh                    # 停止所有服务
    └── add-worker.sh                  # 扩容新Worker节点脚本
```

---

## 部署步骤

> **说明**：以下步骤均需在**对应节点**上执行，请注意每一步前的节点标注。

### 第一步：克隆仓库（所有节点）

```bash
# 在 spark-master、spark-worker1、hadoop-node3 上分别执行
git clone https://github.com/robinyw/tools.git /opt/tools
cd /opt/tools/spark
```

### 第二步：配置 /etc/hosts（所有节点）

```bash
cat >> /etc/hosts <<EOF
192.168.1.10  spark-master
192.168.1.11  spark-worker1
192.168.1.12  hadoop-node3
EOF
```

### 第三步：创建数据目录并同步配置（所有节点）

```bash
# 创建目录
mkdir -p /opt/bigdata/{data/{zookeeper,journalnode,namenode,datanode},logs/{zookeeper,hadoop,spark},config/{hadoop,spark}}

# 复制配置文件
cp config/hadoop/* /opt/bigdata/config/hadoop/
cp config/spark/*  /opt/bigdata/config/spark/
```

### 第四步：启动 ZooKeeper（所有节点，同时执行）

```bash
# 在 spark-master 执行
docker compose -f docker-compose-master.yml up -d zookeeper

# 在 spark-worker1 执行
docker compose -f docker-compose-worker1.yml up -d zookeeper

# 在 hadoop-node3 执行
docker compose -f docker-compose-node3.yml up -d zookeeper
```

验证 ZooKeeper 集群状态：

```bash
# 在任意节点执行
echo "ruok" | nc spark-master 2181
echo "stat" | nc spark-master 2181 | grep "Mode:"
echo "stat" | nc spark-worker1 2181 | grep "Mode:"
echo "stat" | nc hadoop-node3 2181 | grep "Mode:"
# 预期：一台显示 Mode: leader，另外两台显示 Mode: follower
```

### 第五步：启动 JournalNode（所有节点，同时执行）

```bash
# 在 spark-master 执行
docker compose -f docker-compose-master.yml up -d journalnode

# 在 spark-worker1 执行
docker compose -f docker-compose-worker1.yml up -d journalnode

# 在 hadoop-node3 执行
docker compose -f docker-compose-node3.yml up -d journalnode
```

等待 10 秒，确认 JournalNode 启动：

```bash
# 检查端口（在任意节点）
nc -zv spark-master 8485
nc -zv spark-worker1 8485
nc -zv hadoop-node3 8485
```

### 第六步：初始化 NameNode（仅首次部署，在 spark-master 执行）

```bash
# 1. 格式化 ZooKeeper 中的 HDFS HA 状态节点
docker run --rm --network host \
  -v /opt/bigdata/config/hadoop:/opt/hadoop/etc/hadoop \
  apache/hadoop:3.3.6 \
  hdfs zkfc -formatZK -nonInteractive

# 2. 格式化 Active NameNode
docker run --rm --network host \
  -v /opt/bigdata/config/hadoop:/opt/hadoop/etc/hadoop \
  -v /opt/bigdata/data/namenode:/opt/hadoop/data/namenode \
  apache/hadoop:3.3.6 \
  hdfs namenode -format -clusterId mycluster -nonInteractive

# 3. 启动 Active NameNode
docker compose -f docker-compose-master.yml up -d namenode
```

### 第七步：初始化 Standby NameNode（仅首次部署，在 hadoop-node3 执行）

```bash
# bootstrapStandby：从 Active NameNode 同步元数据
docker run --rm --network host \
  -v /opt/bigdata/config/hadoop:/opt/hadoop/etc/hadoop \
  -v /opt/bigdata/data/namenode:/opt/hadoop/data/namenode \
  apache/hadoop:3.3.6 \
  hdfs namenode -bootstrapStandby -nonInteractive

# 启动 Standby NameNode
docker compose -f docker-compose-node3.yml up -d namenode-standby
```

### 第八步：启动 ZKFC（spark-master 和 hadoop-node3）

```bash
# 在 spark-master 执行
docker compose -f docker-compose-master.yml up -d zkfc

# 在 hadoop-node3 执行
docker compose -f docker-compose-node3.yml up -d zkfc
```

### 第九步：启动 ResourceManager（spark-master 和 hadoop-node3）

```bash
# 在 spark-master 执行
docker compose -f docker-compose-master.yml up -d resourcemanager

# 在 hadoop-node3 执行
docker compose -f docker-compose-node3.yml up -d resourcemanager-standby
```

### 第十步：启动 DataNode 和 NodeManager（spark-worker1 和 hadoop-node3）

```bash
# 在 spark-worker1 执行
docker compose -f docker-compose-worker1.yml up -d datanode nodemanager

# 在 hadoop-node3 执行
docker compose -f docker-compose-node3.yml up -d datanode nodemanager
```

### 第十一步：创建 HDFS 目录并启动 Spark HistoryServer（在 spark-master 执行）

```bash
# 创建 Spark 日志目录和 YARN 日志目录
docker run --rm --network host \
  -v /opt/bigdata/config/hadoop:/opt/hadoop/etc/hadoop \
  apache/hadoop:3.3.6 \
  bash -c "
    hdfs dfs -mkdir -p /spark/history && \
    hdfs dfs -mkdir -p /yarn/logs && \
    hdfs dfs -chmod 1777 /spark/history && \
    hdfs dfs -chmod 1777 /yarn/logs
  "

# 启动 Spark HistoryServer
docker compose -f docker-compose-master.yml up -d historyserver
```

也可以直接使用初始化脚本完成以上所有步骤：

```bash
# 在 spark-master 上执行（会交互式引导完成初始化）
chmod +x scripts/init.sh
./scripts/init.sh
```

---

## 启动顺序

### 首次部署启动顺序

> 按照部署步骤第四步至第十一步依次执行。

```
ZooKeeper (3节点) → JournalNode (3节点) → formatZK → format NameNode
→ Active NameNode → bootstrapStandby → Standby NameNode
→ ZKFC (2节点) → ResourceManager (2节点)
→ DataNode (2节点) → NodeManager (2节点)
→ 创建HDFS目录 → Spark HistoryServer
```

### 日常启动顺序（重启集群）

```bash
# 在每台节点上执行对应脚本，或分步执行：

# Step 1: ZooKeeper（三节点同时启动）
docker compose -f docker-compose-<node>.yml up -d zookeeper

# Step 2: JournalNode（三节点同时启动）
docker compose -f docker-compose-<node>.yml up -d journalnode

# Step 3: Active NameNode（spark-master）
docker compose -f docker-compose-master.yml up -d namenode

# Step 4: Standby NameNode（hadoop-node3）
docker compose -f docker-compose-node3.yml up -d namenode-standby

# Step 5: ZKFC（spark-master 和 hadoop-node3）
docker compose -f docker-compose-<node>.yml up -d zkfc

# Step 6: ResourceManager（spark-master 和 hadoop-node3）
docker compose -f docker-compose-<node>.yml up -d resourcemanager

# Step 7: DataNode + NodeManager（spark-worker1 和 hadoop-node3）
docker compose -f docker-compose-<node>.yml up -d datanode nodemanager

# Step 8: Spark HistoryServer（spark-master）
docker compose -f docker-compose-master.yml up -d historyserver
```

或直接使用脚本（在各节点分别执行）：

```bash
chmod +x scripts/start-all.sh
./scripts/start-all.sh
```

---

## 验证集群状态

### 验证 ZooKeeper

```bash
# 检查 ZooKeeper 集群成员状态
for host in spark-master spark-worker1 hadoop-node3; do
  echo "=== $host ==="
  echo "stat" | nc $host 2181 | grep -E "Mode:|Connections:"
done
```

### 验证 HDFS HA 状态

```bash
# 查看 NameNode HA 状态（在 spark-master 执行）
docker exec namenode hdfs haadmin -getServiceState nn1
docker exec namenode hdfs haadmin -getServiceState nn2
# 预期：nn1 显示 active，nn2 显示 standby

# 查看 DataNode 列表
docker exec namenode hdfs dfsadmin -report | grep -E "^(Name|Live|Dead)"

# 查看 HDFS 文件系统状态
docker exec namenode hdfs dfsadmin -report
```

### 验证 YARN HA 状态

```bash
# 查看 ResourceManager HA 状态（在 spark-master 执行）
docker exec resourcemanager yarn rmadmin -getServiceState rm1
docker exec resourcemanager yarn rmadmin -getServiceState rm2
# 预期：rm1 显示 active，rm2 显示 standby

# 查看 NodeManager 列表
docker exec resourcemanager yarn node -list
```

### 验证 Spark HistoryServer

```bash
# 检查 HistoryServer 进程
docker exec spark-historyserver ps aux | grep HistoryServer

# 或直接访问 Web UI
curl -s http://spark-master:18080 | grep -i "spark history"
```

### 运行测试任务

```bash
# 运行 Spark Pi 测试（在 spark-master 执行）
docker run --rm --network host \
  -v /opt/bigdata/config/hadoop:/opt/hadoop/etc/hadoop \
  -v /opt/bigdata/config/spark:/opt/spark/conf \
  apache/spark:3.5.1 \
  spark-submit \
    --class org.apache.spark.examples.SparkPi \
    --master yarn \
    --deploy-mode cluster \
    /opt/spark/examples/jars/spark-examples_2.12-3.5.1.jar 10
```

---

## Web UI 访问地址

| 服务 | 地址 | 说明 |
|------|------|------|
| HDFS NameNode (Active) | http://spark-master:9870 | HDFS 管理界面 |
| HDFS NameNode (Standby) | http://hadoop-node3:9870 | HDFS HA 备节点 |
| YARN ResourceManager (Active) | http://spark-master:8088 | YARN 任务管理 |
| YARN ResourceManager (Standby) | http://hadoop-node3:8088 | YARN HA 备节点 |
| Spark History Server | http://spark-master:18080 | Spark 历史任务查看 |
| MapReduce History Server | http://spark-master:19888 | MR 历史任务查看 |

> **注意**：如果从公网访问，需在防火墙/安全组中开放对应端口，建议仅对可信 IP 开放。

---

## 扩容 Worker 节点

### 步骤一：准备新节点

1. 创建新云服务器（建议配置：8C 32G 500G）
2. 安装 Docker 和 Docker Compose
3. 配置内网 IP 和主机名（例如 `spark-worker2`，IP `192.168.1.13`）

### 步骤二：更新所有节点的 /etc/hosts

在 **所有现有节点** 和 **新节点** 上执行：

```bash
echo "192.168.1.13  spark-worker2" >> /etc/hosts
```

### 步骤三：更新 workers 配置文件

在 `config/hadoop/workers` 中添加新节点：

```
spark-worker1
hadoop-node3
spark-worker2    # 新增
```

### 步骤四：执行扩容脚本（在 spark-master 执行）

```bash
chmod +x scripts/add-worker.sh
./scripts/add-worker.sh 192.168.1.13 spark-worker2
```

脚本将自动完成：
- SSH 连接验证
- 目录创建
- 配置文件同步
- 启动 DataNode 和 NodeManager
- 执行 `hdfs dfsadmin -refreshNodes`
- 执行 `yarn rmadmin -refreshNodes`

### 步骤五：触发 HDFS 数据均衡（可选）

```bash
# 在 spark-master 执行
docker run --rm --network host \
  -v /opt/bigdata/config/hadoop:/opt/hadoop/etc/hadoop \
  apache/hadoop:3.3.6 \
  hdfs balancer -threshold 10
```

---

## 常见问题排查（FAQ）

### Q1: ZooKeeper 无法形成 Quorum

**症状**：`echo stat | nc <host> 2181` 超时或报错

**排查**：
```bash
# 检查容器状态
docker ps | grep zookeeper

# 查看 ZooKeeper 日志
docker logs zookeeper --tail 50

# 检查 2888/3888 端口
nc -zv spark-master 2888
nc -zv spark-master 3888
```

**常见原因**：
- 内网防火墙未开放 2888/3888 端口
- `/etc/hosts` 中主机名解析不正确
- ZOO_MY_ID 配置重复

---

### Q2: NameNode 启动失败 / HDFS 无法进入 Safe Mode

**症状**：`docker logs namenode` 显示格式化错误或 Safe Mode

**排查**：
```bash
# 查看 NameNode 日志
docker logs namenode --tail 100

# 检查 JournalNode 是否全部运行
nc -zv spark-master 8485
nc -zv spark-worker1 8485
nc -zv hadoop-node3 8485

# 手动退出 Safe Mode
docker exec namenode hdfs dfsadmin -safemode leave
```

---

### Q3: Standby NameNode bootstrapStandby 失败

**症状**：`bootstrapStandby` 报错 "name directory is not empty"

**解决**：
```bash
# 清空 Standby NameNode 数据目录后重试
rm -rf /opt/bigdata/data/namenode/*

docker run --rm --network host \
  -v /opt/bigdata/config/hadoop:/opt/hadoop/etc/hadoop \
  -v /opt/bigdata/data/namenode:/opt/hadoop/data/namenode \
  apache/hadoop:3.3.6 \
  hdfs namenode -bootstrapStandby -nonInteractive
```

---

### Q4: YARN NodeManager 资源不足

**症状**：任务提交失败，提示内存不足

**排查**：
```bash
# 查看 NodeManager 资源
docker exec nodemanager yarn node -list -showDetails

# 调整 yarn-site.xml 中的资源配置
# yarn.nodemanager.resource.memory-mb（单位：MB）
# yarn.nodemanager.resource.cpu-vcores
```

---

### Q5: Spark 任务找不到历史记录

**症状**：Spark History Server 无任务记录

**排查**：
```bash
# 确认 HDFS 历史目录存在
docker exec namenode hdfs dfs -ls /spark/history

# 确认 spark-defaults.conf 中 eventLog 配置正确
grep eventLog /opt/bigdata/config/spark/spark-defaults.conf

# 查看 HistoryServer 日志
docker logs spark-historyserver --tail 50
```

---

### Q6: 容器 OOM 被杀

**症状**：`docker ps` 显示容器频繁重启

**排查**：
```bash
# 检查宿主机内存使用
free -h

# 检查容器内存
docker stats --no-stream

# 查看 OOM 记录
dmesg | grep -i "oom"
```

**解决**：适当调低 `YARN_RESOURCEMANAGER_OPTS`、`YARN_NODEMANAGER_OPTS` 中的 `-Xmx` 值

---

## 生产运维建议

### 1. 数据备份

```bash
# 定期备份 NameNode 元数据（在 spark-master 执行）
# 推荐使用 cron 每日备份
0 2 * * * rsync -av /opt/bigdata/data/namenode/ /backup/namenode-$(date +\%Y\%m\%d)/
```

### 2. 日志管理

- 建议配置 Docker 日志限制，防止磁盘打满：

```bash
# 在 docker-compose 中为每个服务添加：
logging:
  driver: "json-file"
  options:
    max-size: "500m"
    max-file: "5"
```

### 3. 监控告警

建议部署以下监控组件：
- **Prometheus + Grafana**：监控 HDFS/YARN/JVM 指标
- **Alertmanager**：磁盘使用率 > 80%、NameNode GC > 1s 时告警

关键监控指标：
```
hdfs_capacity_used_percent   # HDFS 使用率
yarn_cluster_memory_mb       # YARN 可用内存
zookeeper_outstanding_requests  # ZooKeeper 积压请求数
jvm_memory_heap_used         # JVM 堆内存使用
```

### 4. NameNode GC 调优

在 `docker-compose-master.yml` 中为 namenode 服务添加：

```yaml
environment:
  HDFS_NAMENODE_OPTS: "-Xms4g -Xmx4g -XX:+UseG1GC -XX:MaxGCPauseMillis=200"
```

### 5. 磁盘容量规划

| 节点 | 数据目录 | 建议磁盘 | 说明 |
|------|---------|---------|------|
| spark-master | /opt/bigdata/data/namenode | 50G+ | NameNode 元数据，建议 SSD |
| spark-worker1 | /opt/bigdata/data/datanode | 400G+ | HDFS 数据块存储 |
| hadoop-node3 | /opt/bigdata/data/datanode | 150G+ | HDFS 数据块（副本） |

### 6. 定期维护任务

```bash
# 每周执行 HDFS 数据均衡
hdfs balancer -threshold 10

# 每月检查 NameNode edit logs 积压
hdfs haadmin -getAllServiceState

# 检查 ZooKeeper 磁盘占用
du -sh /opt/bigdata/data/zookeeper
du -sh /opt/bigdata/logs/zookeeper
```

### 7. 故障转移演练

建议每季度演练一次 NameNode 故障转移：

```bash
# 模拟 Active NameNode 故障（在 spark-master 执行）
docker stop namenode
# 预期：hadoop-node3 上的 Standby NameNode 在 30s 内自动提升为 Active

# 验证故障转移
docker exec namenode-standby hdfs haadmin -getServiceState nn2
# 应显示 active

# 恢复 spark-master 上的 NameNode
docker compose -f docker-compose-master.yml up -d namenode
# 此时 nn1 以 Standby 状态加入
```

---

*文档最后更新：2024 年*  
*维护者：运维团队*
