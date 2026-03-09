#!/bin/bash

# =============================================
# ECS-2 (172.16.0.21) 系统初始化脚本
# =============================================

set -e

echo "📁 创建数据目录..."
mkdir -p /data/elasticsearch/node3/data
mkdir -p /data/elasticsearch/node3/logs
mkdir -p /data/elasticsearch/kibana/data

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

echo "🔑 设置目录权限..."
chown -R 1000:1000 /data/elasticsearch/node3
chown -R 1000:1000 /data/elasticsearch/kibana

echo "✅ ECS-2 初始化完成！"
