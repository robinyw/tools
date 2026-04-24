#!/bin/bash
# =============================================================================
# add-worker.sh - 扩容新 Worker 节点脚本
# 用法：./add-worker.sh <新节点IP> <新节点主机名>
# 示例：./add-worker.sh 192.168.1.13 spark-worker2
#
# 说明：
#   1. 新节点需预先配置好 Docker 环境
#   2. 新节点需与集群内网互通
#   3. 在 spark-master 上执行此脚本
# =============================================================================

set -e

MASTER_HOST="spark-master"

if [[ $# -lt 2 ]]; then
  echo "用法: $0 <新节点IP> <新节点主机名>"
  echo "示例: $0 192.168.1.13 spark-worker2"
  exit 1
fi

NEW_NODE_IP="$1"
NEW_NODE_HOST="$2"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

echo "========================================"
echo " 扩容新 Worker 节点: $NEW_NODE_HOST ($NEW_NODE_IP)"
echo "========================================"

# ---- Step 1: 检测新节点 SSH 连通性 ----
echo ""
echo "[Step 1] 检测新节点 SSH 连通性..."
if ! ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no "root@$NEW_NODE_IP" "echo '  ✅ SSH 连接正常'" 2>/dev/null; then
  echo "  ❌ 无法 SSH 到 $NEW_NODE_IP，请检查网络和 SSH 配置"
  exit 1
fi

# ---- Step 2: 初始化新节点目录 ----
echo ""
echo "[Step 2] 在新节点上创建数据目录..."
ssh -o StrictHostKeyChecking=no "root@$NEW_NODE_IP" bash <<'REMOTE_EOF'
set -e
for dir in \
  /opt/bigdata/data/datanode \
  /opt/bigdata/logs/hadoop \
  /opt/bigdata/config/hadoop \
  /opt/bigdata/config/spark; do
  mkdir -p "$dir"
  echo "  ✅ $dir"
done
REMOTE_EOF

# ---- Step 3: 同步配置文件到新节点 ----
echo ""
echo "[Step 3] 同步 Hadoop/Spark 配置文件到新节点..."
rsync -avz --delete \
  /opt/bigdata/config/hadoop/ \
  "root@$NEW_NODE_IP:/opt/bigdata/config/hadoop/"

rsync -avz --delete \
  /opt/bigdata/config/spark/ \
  "root@$NEW_NODE_IP:/opt/bigdata/config/spark/"

echo "  ✅ 配置文件同步完成"

# ---- Step 4: 上传 Docker Compose 文件 ----
echo ""
echo "[Step 4] 上传新节点的 docker-compose 文件..."

# 生成新节点专属的 docker-compose 文件
NEW_COMPOSE="/tmp/docker-compose-${NEW_NODE_HOST}.yml"
cat > "$NEW_COMPOSE" <<COMPOSE_EOF
version: '3.8'

services:

  datanode:
    image: apache/hadoop:3.3.6
    container_name: datanode
    network_mode: host
    restart: unless-stopped
    volumes:
      - /opt/bigdata/config/hadoop:/opt/hadoop/etc/hadoop
      - /opt/bigdata/data/datanode:/opt/hadoop/data/datanode
      - /opt/bigdata/logs/hadoop:/opt/hadoop/logs
    command: hdfs datanode

  nodemanager:
    image: apache/hadoop:3.3.6
    container_name: nodemanager
    network_mode: host
    restart: unless-stopped
    environment:
      YARN_NODEMANAGER_OPTS: "-Xmx2g"
    volumes:
      - /opt/bigdata/config/hadoop:/opt/hadoop/etc/hadoop
      - /opt/bigdata/logs/hadoop:/opt/hadoop/logs
    command: yarn nodemanager
    depends_on:
      - datanode
COMPOSE_EOF

scp "$NEW_COMPOSE" "root@$NEW_NODE_IP:/opt/bigdata/docker-compose.yml"
echo "  ✅ docker-compose 文件已上传"

# ---- Step 5: 在新节点启动 DataNode 和 NodeManager ----
echo ""
echo "[Step 5] 在新节点启动 DataNode 和 NodeManager..."
ssh -o StrictHostKeyChecking=no "root@$NEW_NODE_IP" \
  "cd /opt/bigdata && docker compose up -d"
echo "  ✅ DataNode 和 NodeManager 已启动"

# ---- Step 6: 刷新 HDFS DataNode 列表 ----
echo ""
echo "[Step 6] 刷新 HDFS DataNode 列表..."
sleep 15
docker run --rm --network host \
  -v /opt/bigdata/config/hadoop:/opt/hadoop/etc/hadoop \
  apache/hadoop:3.3.6 \
  hdfs dfsadmin -refreshNodes
echo "  ✅ HDFS DataNode 列表已刷新"

# ---- Step 7: 刷新 YARN NodeManager 列表 ----
echo ""
echo "[Step 7] 刷新 YARN NodeManager 列表..."
docker run --rm --network host \
  -v /opt/bigdata/config/hadoop:/opt/hadoop/etc/hadoop \
  apache/hadoop:3.3.6 \
  yarn rmadmin -refreshNodes
echo "  ✅ YARN NodeManager 列表已刷新"

# ---- Step 8: 验证新节点已加入集群 ----
echo ""
echo "[Step 8] 验证新节点状态..."
echo "  HDFS DataNode 列表："
docker run --rm --network host \
  -v /opt/bigdata/config/hadoop:/opt/hadoop/etc/hadoop \
  apache/hadoop:3.3.6 \
  hdfs dfsadmin -report | grep -E "^(Name|Live datanodes)" | head -20

echo ""
echo "  YARN NodeManager 列表："
docker run --rm --network host \
  -v /opt/bigdata/config/hadoop:/opt/hadoop/etc/hadoop \
  apache/hadoop:3.3.6 \
  yarn node -list 2>/dev/null | grep -v "^$" | head -20

# ---- 完成 ----
echo ""
echo "========================================"
echo " 新节点 $NEW_NODE_HOST ($NEW_NODE_IP) 扩容完成！"
echo ""
echo " ⚠️  后续操作提示："
echo "   1. 将 $NEW_NODE_HOST 添加到 config/hadoop/workers 文件"
echo "   2. 将 $NEW_NODE_HOST 和 $NEW_NODE_IP 添加到所有节点的 /etc/hosts"
echo "   3. 根据需要触发 HDFS 数据均衡："
echo "      hdfs balancer -threshold 10"
echo "========================================"

# 清理临时文件
rm -f "$NEW_COMPOSE"
