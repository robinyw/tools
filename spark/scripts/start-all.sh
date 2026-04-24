#!/bin/bash
# =============================================================================
# start-all.sh - 启动所有节点服务
# 说明：日常启动脚本，按正确顺序启动各组件
#       首次部署请先执行 init.sh
# =============================================================================
#
# 启动顺序：
#   1. 所有节点：ZooKeeper（需要 Quorum 就绪才能进行下一步）
#   2. 所有节点：JournalNode
#   3. spark-master：Active NameNode
#   4. hadoop-node3：Standby NameNode
#   5. 所有节点（NameNode 就绪后）：ZKFC
#   6. spark-master：ResourceManager (Active)
#   7. hadoop-node3：ResourceManager (Standby)
#   8. spark-worker1 + hadoop-node3：DataNode
#   9. spark-worker1 + hadoop-node3：NodeManager
#  10. spark-master：Spark HistoryServer
#
# =============================================================================

set -e

MASTER_HOST="spark-master"
WORKER1_HOST="spark-worker1"
NODE3_HOST="hadoop-node3"

COMPOSE_MASTER="docker-compose-master.yml"
COMPOSE_WORKER1="docker-compose-worker1.yml"
COMPOSE_NODE3="docker-compose-node3.yml"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$(dirname "$SCRIPT_DIR")"

echo "========================================"
echo " 启动 Spark + HDFS + YARN HA 集群"
echo "========================================"

# 判断当前所在节点
CURRENT_HOST=$(hostname)

start_service() {
  local compose_file=$1
  local service=$2
  echo "  ▶ 启动 $service ..."
  docker compose -f "$BASE_DIR/$compose_file" up -d "$service"
}

wait_seconds() {
  echo "  ⏳ 等待 ${1}s ..."
  sleep "$1"
}

# ---- Step 1: ZooKeeper ----
echo ""
echo "[Step 1] 启动 ZooKeeper（需在三台节点上执行）"

if [[ "$CURRENT_HOST" == "$MASTER_HOST" ]]; then
  start_service "$COMPOSE_MASTER" zookeeper
elif [[ "$CURRENT_HOST" == "$WORKER1_HOST" ]]; then
  start_service "$COMPOSE_WORKER1" zookeeper
elif [[ "$CURRENT_HOST" == "$NODE3_HOST" ]]; then
  start_service "$COMPOSE_NODE3" zookeeper
fi

echo "  ⚠️  请确保三台节点 ZooKeeper 均已启动"
read -r -p "  ZooKeeper Quorum 就绪？[y/N] " zk_ready
[[ "$zk_ready" =~ ^[Yy]$ ]] || { echo "  ⏹  请先确保 ZooKeeper 就绪"; exit 1; }
wait_seconds 10

# ---- Step 2: JournalNode ----
echo ""
echo "[Step 2] 启动 JournalNode（需在三台节点上执行）"

if [[ "$CURRENT_HOST" == "$MASTER_HOST" ]]; then
  start_service "$COMPOSE_MASTER" journalnode
elif [[ "$CURRENT_HOST" == "$WORKER1_HOST" ]]; then
  start_service "$COMPOSE_WORKER1" journalnode
elif [[ "$CURRENT_HOST" == "$NODE3_HOST" ]]; then
  start_service "$COMPOSE_NODE3" journalnode
fi

echo "  ⚠️  请确保三台节点 JournalNode 均已启动"
read -r -p "  JournalNode 全部就绪？[y/N] " jn_ready
[[ "$jn_ready" =~ ^[Yy]$ ]] || { echo "  ⏹  请先确保 JournalNode 就绪"; exit 1; }
wait_seconds 10

# ---- Step 3: Active NameNode (spark-master) ----
echo ""
echo "[Step 3] 启动 Active NameNode（在 spark-master 执行）"

if [[ "$CURRENT_HOST" == "$MASTER_HOST" ]]; then
  start_service "$COMPOSE_MASTER" namenode
  wait_seconds 20
fi

# ---- Step 4: Standby NameNode (hadoop-node3) ----
echo ""
echo "[Step 4] 启动 Standby NameNode（在 hadoop-node3 执行）"

if [[ "$CURRENT_HOST" == "$NODE3_HOST" ]]; then
  start_service "$COMPOSE_NODE3" namenode-standby
  wait_seconds 15
fi

# ---- Step 5: ZKFC ----
echo ""
echo "[Step 5] 启动 ZKFC（spark-master 和 hadoop-node3）"

if [[ "$CURRENT_HOST" == "$MASTER_HOST" ]]; then
  start_service "$COMPOSE_MASTER" zkfc
elif [[ "$CURRENT_HOST" == "$NODE3_HOST" ]]; then
  start_service "$COMPOSE_NODE3" zkfc
fi
wait_seconds 10

# ---- Step 6 & 7: ResourceManager ----
echo ""
echo "[Step 6/7] 启动 ResourceManager"

if [[ "$CURRENT_HOST" == "$MASTER_HOST" ]]; then
  start_service "$COMPOSE_MASTER" resourcemanager
elif [[ "$CURRENT_HOST" == "$NODE3_HOST" ]]; then
  start_service "$COMPOSE_NODE3" resourcemanager-standby
fi
wait_seconds 10

# ---- Step 8: DataNode ----
echo ""
echo "[Step 8] 启动 DataNode（spark-worker1 和 hadoop-node3）"

if [[ "$CURRENT_HOST" == "$WORKER1_HOST" ]]; then
  start_service "$COMPOSE_WORKER1" datanode
elif [[ "$CURRENT_HOST" == "$NODE3_HOST" ]]; then
  start_service "$COMPOSE_NODE3" datanode
fi
wait_seconds 10

# ---- Step 9: NodeManager ----
echo ""
echo "[Step 9] 启动 NodeManager（spark-worker1 和 hadoop-node3）"

if [[ "$CURRENT_HOST" == "$WORKER1_HOST" ]]; then
  start_service "$COMPOSE_WORKER1" nodemanager
elif [[ "$CURRENT_HOST" == "$NODE3_HOST" ]]; then
  start_service "$COMPOSE_NODE3" nodemanager
fi

# ---- Step 10: Spark HistoryServer (spark-master) ----
echo ""
echo "[Step 10] 启动 Spark HistoryServer（在 spark-master 执行）"

if [[ "$CURRENT_HOST" == "$MASTER_HOST" ]]; then
  start_service "$COMPOSE_MASTER" historyserver
fi

echo ""
echo "========================================"
echo " 所有服务启动完成！"
echo ""
echo " Web UI 地址："
echo "   HDFS NameNode (Active) : http://${MASTER_HOST}:9870"
echo "   HDFS NameNode (Standby): http://${NODE3_HOST}:9870"
echo "   YARN ResourceManager   : http://${MASTER_HOST}:8088"
echo "   Spark History Server   : http://${MASTER_HOST}:18080"
echo "   MapReduce History      : http://${MASTER_HOST}:19888"
echo "========================================"
