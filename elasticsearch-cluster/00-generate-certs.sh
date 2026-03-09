#!/bin/bash

# =============================================
# ES 8.17.0 TLS 证书生成脚本
# 在 ECS-1 (172.16.0.20) 上执行
# =============================================

set -e

CERTS_DIR=/data/elasticsearch/certs
mkdir -p ${CERTS_DIR}

echo "📄 生成证书配置文件..."
cat > ${CERTS_DIR}/instances.yml <<EOF
instances:
  - name: es-node1
    ip:
      - 172.16.0.20
  - name: es-node2
    ip:
      - 172.16.0.20
  - name: es-node3
    ip:
      - 172.16.0.21
  - name: kibana
    ip:
      - 172.16.0.21
EOF

echo "🔐 生成 CA 证书..."
docker run --rm \
  -v ${CERTS_DIR}:/certs \
  docker.elastic.co/elasticsearch/elasticsearch:8.17.0 \
  bin/elasticsearch-certutil ca \
    --silent \
    --pem \
    --out /certs/ca.zip

cd ${CERTS_DIR} && unzip -o ca.zip && rm ca.zip

echo "🔐 生成各节点证书..."
docker run --rm \
  -v ${CERTS_DIR}:/certs \
  docker.elastic.co/elasticsearch/elasticsearch:8.17.0 \
  bin/elasticsearch-certutil cert \
    --silent \
    --pem \
    --ca-cert /certs/ca/ca.crt \
    --ca-key /certs/ca/ca.key \
    --in /certs/instances.yml \
    --out /certs/certs.zip

cd ${CERTS_DIR} && unzip -o certs.zip && rm certs.zip

echo "🔑 设置证书权限..."
chmod -R 755 ${CERTS_DIR}
chown -R 1000:1000 ${CERTS_DIR}

echo "✅ 证书生成完成！"
ls -la ${CERTS_DIR}
