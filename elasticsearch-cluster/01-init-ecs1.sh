#!/bin/bash

# =============================================
# ECS-1 (172.16.0.20) 系统初始化脚本
# =============================================

set -e

echo "📁 创建数据目录..."
mkdir -p /data/elasticsearch/node1/data
mkdir -p /data/elasticsearch/node1/logs
mkdir -p /data/elasticsearch/node2/data
mkdir -p /data/elasticsearch/node2/logs

echo "🔧 设置系统参数..."
sysctl -w vm.max_map_count=262144

grep -q 'vm.max_map_count' /etc/sysctl.conf \
  && sed -i 's/vm.max_map_count.*/vm.max_map_count=262144/' /etc/sysctl.conf \
  || echo "vm.max_map_count=262144" >> /etc/sysctl.conf

cat >> /etc/security/limits.conf <<EOF
* soft nofile 65536
* hard nofile 65536
* soft nproc  4096
* hard nproc  4096
EOF

echo "🔑 设置目录权限（UID 1000 为 elasticsearch 容器用户）..."
chown -R 1000:1000 /data/elasticsearch/node1
chown -R 1000:1000 /data/elasticsearch/node2

echo "✅ ECS-1 初始化完成！"
