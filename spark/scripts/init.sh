#!/bin/bash
# =============================================================================
# init.sh - 首次部署初始化脚本
# 说明：仅在首次部署时执行，后续重启请使用 start-all.sh
# =============================================================================

set -e

MASTER_HOST="spark-master"
WORKER1_HOST="spark-worker1"
NODE3_HOST="hadoop-node3"

echo "========================================"
echo " Spark + HDFS + YARN HA 集群初始化脚本"
echo "========================================"

# ---- 基础环境检测 ----
echo ""
echo "[1/6] 检查基础环境..."

check_host() {
  local host=$1
  if ping -c 1 -W 2 "$host" &>/dev/null; then
    echo "  ✅ $host 可达"
  else
    echo "  ❌ $host 不可达，请检查 /etc/hosts 或 DNS 配置"
    exit 1
  fi
}

check_host "$MASTER_HOST"
check_host "$WORKER1_HOST"
check_host "$NODE3_HOST"

if ! command -v docker &>/dev/null; then
  echo "  ❌ Docker 未安装，请先安装 Docker"
  exit 1
fi

if ! command -v docker-compose &>/dev/null && ! docker compose version &>/dev/null; then
  echo "  ❌ Docker Compose 未安装"
  exit 1
fi

echo "  ✅ 环境检测通过"

# ---- 创建宿主机目录 ----
echo ""
echo "[2/6] 创建数据目录..."

BASE_DIRS=(
  /opt/bigdata/data/zookeeper
  /opt/bigdata/data/journalnode
  /opt/bigdata/data/namenode
  /opt/bigdata/data/datanode
  /opt/bigdata/logs/zookeeper
  /opt/bigdata/logs/hadoop
  /opt/bigdata/logs/spark
  /opt/bigdata/config/hadoop
  /opt/bigdata/config/spark
)

for dir in "${BASE_DIRS[@]}"; do
  mkdir -p "$dir"
  echo "  ✅ $dir"
done

# ---- 同步配置文件 ----
echo ""
echo "[3/6] 同步配置文件到 /opt/bigdata/config ..."

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_CONFIG="$SCRIPT_DIR/../config"

cp -r "$REPO_CONFIG/hadoop/"* /opt/bigdata/config/hadoop/
cp -r "$REPO_CONFIG/spark/"*  /opt/bigdata/config/spark/

echo "  ✅ Hadoop 配置已复制到 /opt/bigdata/config/hadoop/"
echo "  ✅ Spark 配置已复制到 /opt/bigdata/config/spark/"

# ---- 提示：在所有节点启动 ZooKeeper，并等待 Quorum 就绪 ----
echo ""
echo "[4/6] 启动 ZooKeeper（需在三台节点上分别执行）..."
echo "  ⚠️  请在 spark-master、spark-worker1、hadoop-node3 上分别执行："
echo "       docker compose -f docker-compose-<节点名>.yml up -d zookeeper"
echo ""
read -r -p "  ZooKeeper 已在三台节点启动完毕？[y/N] " answer
if [[ ! "$answer" =~ ^[Yy]$ ]]; then
  echo "  ⏹  请先启动 ZooKeeper，再继续初始化"
  exit 0
fi

# 等待 ZooKeeper Quorum
echo "  等待 ZooKeeper Quorum 就绪（30s）..."
sleep 30

# ---- 格式化 ZooKeeper（ZKFC 需要） ----
echo ""
echo "[5/6] 格式化 ZooKeeper 中的 HDFS HA 状态节点..."
docker run --rm --network host \
  -v /opt/bigdata/config/hadoop:/opt/hadoop/etc/hadoop \
  apache/hadoop:3.3.6 \
  hdfs zkfc -formatZK -nonInteractive
echo "  ✅ ZooKeeper HA 节点格式化完成"

# ---- 格式化 Active NameNode ----
echo ""
echo "[6/6] 格式化 Active NameNode（spark-master）..."
echo "  ⚠️  此步骤会清空 NameNode 数据，确保是首次部署！"
read -r -p "  确认格式化 NameNode？[y/N] " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
  echo "  ⏹  已取消格式化"
  exit 0
fi

docker run --rm --network host \
  -v /opt/bigdata/config/hadoop:/opt/hadoop/etc/hadoop \
  -v /opt/bigdata/data/namenode:/opt/hadoop/data/namenode \
  apache/hadoop:3.3.6 \
  hdfs namenode -format -clusterId mycluster -nonInteractive
echo "  ✅ Active NameNode 格式化完成"

# ---- 启动 JournalNode（三台节点）----
echo ""
echo "  ⚠️  请在三台节点上分别启动 JournalNode 后继续："
echo "       docker compose -f docker-compose-<节点名>.yml up -d journalnode"
read -r -p "  JournalNode 已在三台节点启动完毕？[y/N] " jn_ready
if [[ ! "$jn_ready" =~ ^[Yy]$ ]]; then
  echo "  ⏹  请先启动 JournalNode，再继续"
  exit 0
fi
sleep 10

# ---- 启动 Active NameNode ----
echo ""
echo "  启动 Active NameNode（spark-master）..."
docker compose -f "$(dirname "$SCRIPT_DIR")/docker-compose-master.yml" up -d namenode
sleep 15

# ---- 在 Standby 节点执行 bootstrapStandby ----
echo ""
echo "  ⚠️  请在 hadoop-node3 上执行以下命令同步 NameNode 元数据："
cat <<'EOF'
  docker run --rm --network host \
    -v /opt/bigdata/config/hadoop:/opt/hadoop/etc/hadoop \
    -v /opt/bigdata/data/namenode:/opt/hadoop/data/namenode \
    apache/hadoop:3.3.6 \
    hdfs namenode -bootstrapStandby -nonInteractive
EOF
read -r -p "  Standby NameNode bootstrapStandby 已完成？[y/N] " standby_ready
if [[ ! "$standby_ready" =~ ^[Yy]$ ]]; then
  echo "  ⏹  请先完成 bootstrapStandby，再继续"
  exit 0
fi

# ---- 创建 HDFS 必要目录 ----
echo ""
echo "  创建 HDFS 目录（/spark/history、/yarn/logs）..."
sleep 10  # 等待 NameNode 完全启动

docker run --rm --network host \
  -v /opt/bigdata/config/hadoop:/opt/hadoop/etc/hadoop \
  apache/hadoop:3.3.6 \
  bash -c "
    hdfs dfs -mkdir -p /spark/history && \
    hdfs dfs -mkdir -p /yarn/logs && \
    hdfs dfs -chmod 1777 /spark/history && \
    hdfs dfs -chmod 1777 /yarn/logs
  "
echo "  ✅ HDFS 目录创建完成"

echo ""
echo "========================================"
echo " 初始化完成！请继续执行 start-all.sh"
echo "========================================"
