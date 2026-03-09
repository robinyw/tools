#!/bin/bash

# =============================================
# ES 密码初始化脚本
# 在 ECS-1 上，集群全部启动后执行
# =============================================

set -e

ES_URL="https://172.16.0.20:9200"
CACERT="/data/elasticsearch/certs/ca/ca.crt"
PASS_FILE="/data/elasticsearch/passwords.txt"

echo "⏳ 等待 ES 集群就绪..."
until curl -s --cacert ${CACERT} ${ES_URL}/_cluster/health | grep -qE 'green|yellow'; do
  echo "  ES 未就绪，等待 10 秒..."
  sleep 10
done
echo "✅ ES 集群已就绪！"

echo ""
echo "🔐 生成内置账号密码..."
docker exec es-node1 bin/elasticsearch-setup-passwords auto \
  --batch \
  --url ${ES_URL} \
  | tee ${PASS_FILE}

echo ""
echo "================================================"
echo "✅ 密码已保存至 ${PASS_FILE}"
echo "⚠️  请立即执行以下操作："
echo "  1. 查看 kibana_system 密码："
echo "     grep 'kibana_system' ${PASS_FILE}"
echo "  2. 填入 ECS-2 的 .env 文件："
echo "     ssh root@172.16.0.21 'vi /data/elasticsearch/ecs2/.env'"
echo "  3. 启动 Kibana："
echo "     ssh root@172.16.0.21 'cd /data/elasticsearch/ecs2 && docker-compose up -d kibana'"
echo "  4. 删除明文密码文件："
echo "     rm -f ${PASS_FILE}"
echo "================================================"
