#!/bin/bash
# =============================================================================
# stop-all.sh - 停止所有节点服务
# 说明：按照与启动相反的顺序停止所有集群服务
#       停止顺序：
#         1. Spark HistoryServer
#         2. NodeManager
#         3. DataNode
#         4. ResourceManager
#         5. ZKFC
#         6. NameNode (Active / Standby)
#         7. JournalNode
#         8. ZooKeeper
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

CURRENT_HOST=$(hostname)

echo "========================================"
echo " 停止 Spark + HDFS + YARN HA 集群"
echo "========================================"

stop_service() {
  local compose_file=$1
  local service=$2
  echo "  ⏹ 停止 $service ..."
  docker compose -f "$BASE_DIR/$compose_file" stop "$service" 2>/dev/null || true
}

# ---- Step 1: Spark HistoryServer ----
echo ""
echo "[Step 1] 停止 Spark HistoryServer"
if [[ "$CURRENT_HOST" == "$MASTER_HOST" ]]; then
  stop_service "$COMPOSE_MASTER" historyserver
fi

# ---- Step 2: NodeManager ----
echo ""
echo "[Step 2] 停止 NodeManager"
if [[ "$CURRENT_HOST" == "$WORKER1_HOST" ]]; then
  stop_service "$COMPOSE_WORKER1" nodemanager
elif [[ "$CURRENT_HOST" == "$NODE3_HOST" ]]; then
  stop_service "$COMPOSE_NODE3" nodemanager
fi

# ---- Step 3: DataNode ----
echo ""
echo "[Step 3] 停止 DataNode"
if [[ "$CURRENT_HOST" == "$WORKER1_HOST" ]]; then
  stop_service "$COMPOSE_WORKER1" datanode
elif [[ "$CURRENT_HOST" == "$NODE3_HOST" ]]; then
  stop_service "$COMPOSE_NODE3" datanode
fi

# ---- Step 4: ResourceManager ----
echo ""
echo "[Step 4] 停止 ResourceManager"
if [[ "$CURRENT_HOST" == "$MASTER_HOST" ]]; then
  stop_service "$COMPOSE_MASTER" resourcemanager
elif [[ "$CURRENT_HOST" == "$NODE3_HOST" ]]; then
  stop_service "$COMPOSE_NODE3" resourcemanager-standby
fi

# ---- Step 5: ZKFC ----
echo ""
echo "[Step 5] 停止 ZKFC"
if [[ "$CURRENT_HOST" == "$MASTER_HOST" ]]; then
  stop_service "$COMPOSE_MASTER" zkfc
elif [[ "$CURRENT_HOST" == "$NODE3_HOST" ]]; then
  stop_service "$COMPOSE_NODE3" zkfc
fi

# ---- Step 6: NameNode ----
echo ""
echo "[Step 6] 停止 NameNode"
if [[ "$CURRENT_HOST" == "$MASTER_HOST" ]]; then
  stop_service "$COMPOSE_MASTER" namenode
elif [[ "$CURRENT_HOST" == "$NODE3_HOST" ]]; then
  stop_service "$COMPOSE_NODE3" namenode-standby
fi

# ---- Step 7: JournalNode ----
echo ""
echo "[Step 7] 停止 JournalNode"
if [[ "$CURRENT_HOST" == "$MASTER_HOST" ]]; then
  stop_service "$COMPOSE_MASTER" journalnode
elif [[ "$CURRENT_HOST" == "$WORKER1_HOST" ]]; then
  stop_service "$COMPOSE_WORKER1" journalnode
elif [[ "$CURRENT_HOST" == "$NODE3_HOST" ]]; then
  stop_service "$COMPOSE_NODE3" journalnode
fi

# ---- Step 8: ZooKeeper ----
echo ""
echo "[Step 8] 停止 ZooKeeper"
if [[ "$CURRENT_HOST" == "$MASTER_HOST" ]]; then
  stop_service "$COMPOSE_MASTER" zookeeper
elif [[ "$CURRENT_HOST" == "$WORKER1_HOST" ]]; then
  stop_service "$COMPOSE_WORKER1" zookeeper
elif [[ "$CURRENT_HOST" == "$NODE3_HOST" ]]; then
  stop_service "$COMPOSE_NODE3" zookeeper
fi

echo ""
echo "========================================"
echo " 所有服务已停止"
echo "========================================"
