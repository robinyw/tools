# Elasticsearch & Kibana 用户权限配置指南

> 适用版本：Elasticsearch & Kibana 8.17.0  
> 前提条件：Security 已启用，`elastic` 超级管理员账号可用

---

## 一、权限规划总览

| 用户 | 角色 | 可访问索引 | 说明 |
|------|------|-----------|------|
| `elastic` | 超级管理员 | 全部 | 系统内置，负责全局管理和用户权限管理 |
| `business_user` | `business_role` | `order-*` | 业务系统用户，可对 order 索引进行增删改查及管理 |
| `ops_user` | `ops_role` | `logs-*` | 运维人员，可对 logs 索引进行增删改查及管理 |
| `data_ops_user` | `data_ops_role` | 全部索引 | 数据运维人员，拥有数据管理+Kibana管理权限，但不能管理用户和角色 |

---

## 二、方式一：通过 Kibana 后台页面创建

### 2.1 创建角色

进入 **Kibana > Management > Security > Roles**，点击 **Create role**。

#### business_role
- **Index permissions**:
  - Indices: `order-*`
  - Privileges: `all`

#### ops_role
- **Index permissions**:
  - Indices: `logs-*`
  - Privileges: `all`

#### data_ops_role
- **Cluster privileges**: `monitor`、`manage`、`manage_index_templates`、`manage_ilm`、`manage_pipeline`、`manage_snapshots`
- **Index permissions**:
  - Indices: `*`
  - Privileges: `all`
- **Kibana privileges**（在 Kibana section 添加）:
  - Space: `*`
  - Privileges: `All`（选择所有 feature 的 All 权限，**不勾选** Security/User Management）

### 2.2 创建用户

进入 **Kibana > Management > Security > Users**，点击 **Create user**。

| 用户名 | 密码 | 绑定角色 |
|--------|------|---------|
| `business_user` | 自定义 | `business_role` |
| `ops_user` | 自定义 | `ops_role` |
| `data_ops_user` | 自定义 | `data_ops_role` |

### 2.3 创建 Data View

进入 **Kibana > Management > Stack Management > Data Views**，点击 **Create data view**。

| Name | Index pattern |
|------|--------------|
| `order-*` | `order-*` |
| `logs-*` | `logs-*` |

---

## 三、方式二：通过 REST API 接口创建

> 所有接口均使用 `elastic` 账号认证。  
> `-k` 参数用于跳过自签名证书校验，若使用正式证书可去掉。  
> 请将 `<your-es-host>`、`<your-kibana-host>`、`<your-password>` 替换为实际值。

### 3.1 创建角色

#### business_role（order-* 完整权限）

```bash
curl -X POST "https://<your-es-host>:9200/_security/role/business_role" \
  -H "Content-Type: application/json" \
  -u elastic:<your-password> \
  -k \
  -d '{
    "indices": [
      {
        "names": ["order-*"],
        "privileges": ["all"]
      }
    ]
  }'
```

#### ops_role（logs-* 完整权限）

```bash
curl -X POST "https://<your-es-host>:9200/_security/role/ops_role" \
  -H "Content-Type: application/json" \
  -u elastic:<your-password> \
  -k \
  -d '{
    "indices": [
      {
        "names": ["logs-*"],
        "privileges": ["all"]
      }
    ]
  }'
```

#### data_ops_role（数据运维人员，全索引管理 + Kibana 管理，不含用户权限管理）

```bash
curl -X POST "https://<your-es-host>:9200/_security/role/data_ops_role" \
  -H "Content-Type: application/json" \
  -u elastic:<your-password> \
  -k \
  -d '{
    "cluster": [
      "monitor",
      "manage",
      "manage_index_templates",
      "manage_ilm",
      "manage_pipeline",
      "manage_snapshots"
    ],
    "indices": [
      {
        "names": ["*"],
        "privileges": ["all"]
      }
    ],
    "applications": [
      {
        "application": "kibana-.kibana",
        "privileges": [
          "feature_discover.all",
          "feature_dashboard.all",
          "feature_visualize.all",
          "feature_canvas.all",
          "feature_maps.all",
          "feature_ml.all",
          "feature_indexPatterns.all",
          "feature_savedObjectsManagement.all",
          "feature_ingestManager.all",
          "feature_monitoring.all",
          "feature_alerting.all",
          "feature_actions.all",
          "feature_dataViews.all",
          "feature_advancedSettings.all",
          "feature_devTools.all",
          "feature_snapshotRestore.all",
          "feature_indexManagement.all",
          "feature_rollup.all",
          "feature_transform.all",
          "feature_crossClusterReplication.all",
          "feature_remoteClusters.all",
          "feature_licenseMgmt.all"
        ],
        "resources": ["*"]
      }
    ]
  }'
```

---

### 3.2 创建用户

#### business_user

```bash
curl -X POST "https://<your-es-host>:9200/_security/user/business_user" \
  -H "Content-Type: application/json" \
  -u elastic:<your-password> \
  -k \
  -d '{
    "password": "<business-user-password>",
    "roles": ["business_role"],
    "full_name": "Business User",
    "email": ""
  }'
```

#### ops_user

```bash
curl -X POST "https://<your-es-host>:9200/_security/user/ops_user" \
  -H "Content-Type: application/json" \
  -u elastic:<your-password> \
  -k \
  -d '{
    "password": "<ops-user-password>",
    "roles": ["ops_role"],
    "full_name": "Ops User",
    "email": ""
  }'
```

#### data_ops_user

```bash
curl -X POST "https://<your-es-host>:9200/_security/user/data_ops_user" \
  -H "Content-Type: application/json" \
  -u elastic:<your-password> \
  -k \
  -d '{
    "password": "<data-ops-password>",
    "roles": ["data_ops_role"],
    "full_name": "Data Ops User",
    "email": ""
  }'
```

---

### 3.3 创建 Data View（Kibana API）

> Kibana API 必须携带 `kbn-xsrf: true` Header。

#### order-* Data View

```bash
curl -X POST "https://<your-kibana-host>:5601/api/data_views/data_view" \
  -H "Content-Type: application/json" \
  -H "kbn-xsrf: true" \
  -u elastic:<your-password> \
  -k \
  -d '{
    "data_view": {
      "title": "order-*",
      "name": "order-*"
    }
  }'
```

#### logs-* Data View

```bash
curl -X POST "https://<your-kibana-host>:5601/api/data_views/data_view" \
  -H "Content-Type: application/json" \
  -H "kbn-xsrf: true" \
  -u elastic:<your-password> \
  -k \
  -d '{
    "data_view": {
      "title": "logs-*",
      "name": "logs-*"
    }
  }'
```

---

## 四、验证配置

### 4.1 验证角色

```bash
# 验证 business_role
curl -X GET "https://<your-es-host>:9200/_security/role/business_role" \
  -u elastic:<your-password> -k

# 验证 ops_role
curl -X GET "https://<your-es-host>:9200/_security/role/ops_role" \
  -u elastic:<your-password> -k

# 验证 data_ops_role
curl -X GET "https://<your-es-host>:9200/_security/role/data_ops_role" \
  -u elastic:<your-password> -k
```

### 4.2 验证用户

```bash
# 验证 business_user
curl -X GET "https://<your-es-host>:9200/_security/user/business_user" \
  -u elastic:<your-password> -k

# 验证 ops_user
curl -X GET "https://<your-es-host>:9200/_security/user/ops_user" \
  -u elastic:<your-password> -k

# 验证 data_ops_user
curl -X GET "https://<your-es-host>:9200/_security/user/data_ops_user" \
  -u elastic:<your-password> -k
```

### 4.3 验证数据隔离

```bash
# business_user 访问 order-*（应该成功）
curl -X GET "https://<your-es-host>:9200/order-*/_search" \
  -u business_user:<business-user-password> -k

# business_user 访问 logs-*（应该返回权限拒绝 403）
curl -X GET "https://<your-es-host>:9200/logs-*/_search" \
  -u business_user:<business-user-password> -k

# ops_user 访问 logs-*（应该成功）
curl -X GET "https://<your-es-host>:9200/logs-*/_search" \
  -u ops_user:<ops-user-password> -k

# ops_user 访问 order-*（应该返回权限拒绝 403）
curl -X GET "https://<your-es-host>:9200/order-*/_search" \
  -u ops_user:<ops-user-password> -k
```

### 4.4 验证索引管理权限

```bash
# business_user 创建 order-test 索引（应该成功）
curl -X PUT "https://<your-es-host>:9200/order-test" \
  -u business_user:<business-user-password> -k

# business_user 写入文档（应该成功）
curl -X PUT "https://<your-es-host>:9200/order-test/_doc/1" \
  -H "Content-Type: application/json" \
  -u business_user:<business-user-password> -k \
  -d '{"name": "test order", "value": 1000}'

# business_user 删除 order-test 索引（应该成功）
curl -X DELETE "https://<your-es-host>:9200/order-test" \
  -u business_user:<business-user-password> -k
```

---

## 五、权限说明汇总

### 索引权限（Index Privileges）

| 权限 | 说明 |
|------|------|
| `read` | 只读，包括搜索和 get 文档 |
| `view_index_metadata` | 查看索引元数据（mapping、settings 等） |
| `write` | 写入、更新、删除文档 |
| `manage` | 索引管理（创建、删除、修改 mapping 等） |
| `all` | 以上全部权限的组合 |

### 集群权限（Cluster Privileges）

| 权限 | 说明 |
|------|------|
| `monitor` | 查看集群状态和统计信息 |
| `manage` | 集群管理（不含用户权限管理） |
| `manage_index_templates` | 管理索引模板 |
| `manage_ilm` | 索引生命周期管理 |
| `manage_pipeline` | Ingest Pipeline 管理 |
| `manage_snapshots` | 快照和备份管理 |
| `manage_security` | 用户和角色管理（**仅 elastic 拥有，data_ops_role 不含此权限**） |

---

## 六、注意事项

> ⚠️ `data_ops_role` **不包含** `manage_security` 权限，因此 `data_ops_user` **无法管理用户和角色**，该能力仅保留给 `elastic` 超级管理员。

> ⚠️ 若 ES 使用自签名证书，curl 命令需加 `-k` 参数；若使用正式 CA 证书，可将 `-k` 替换为 `--cacert /path/to/ca.crt`。

> ⚠️ 修改已有角色时，使用 `PUT` 方法（会覆盖原有配置）；创建新角色时，使用 `POST` 或 `PUT` 均可。