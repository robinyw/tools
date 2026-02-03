# OpenCode 最佳实践和注意事项

本文档详细介绍使用 OpenCode 进行开发时的最佳实践、注意事项和常见问题解决方案。

## 目录
- [简介](#简介)
- [最佳实践](#最佳实践)
  - [代码规范](#代码规范)
  - [版本控制](#版本控制)
  - [协作开发](#协作开发)
  - [代码审查](#代码审查)
  - [测试策略](#测试策略)
  - [文档管理](#文档管理)
  - [性能优化](#性能优化)
  - [安全性](#安全性)
- [注意事项](#注意事项)
  - [常见陷阱](#常见陷阱)
  - [环境配置](#环境配置)
  - [依赖管理](#依赖管理)
  - [错误处理](#错误处理)
- [工作流程建议](#工作流程建议)
- [常见问题解答](#常见问题解答)

---

## 简介

OpenCode 是一个现代化的开发平台，支持多种编程语言和框架。正确使用 OpenCode 可以显著提高开发效率和代码质量。本文档总结了在实际项目中使用 OpenCode 的经验和教训。

---

## 最佳实践

### 代码规范

#### 1. 遵循编程语言规范

- **统一代码风格**：使用项目统一的代码格式化工具（如 Prettier、Black、gofmt）
- **命名规范**：
  - 变量名使用小驼峰命名法（camelCase）
  - 类名使用大驼峰命名法（PascalCase）
  - 常量使用全大写下划线分隔（UPPER_SNAKE_CASE）
  - 函数名应清晰表达其功能

```javascript
// 好的示例
const userProfile = getUserProfile();
const MAX_RETRY_COUNT = 3;

// 不好的示例
const up = getUP();
const max = 3;
```

#### 2. 保持代码简洁

- 每个函数只做一件事
- 避免深层嵌套（建议不超过 3 层）
- 单个函数长度不超过 50 行
- 及时重构重复代码

```python
# 好的示例
def validate_email(email):
    return is_valid_format(email) and is_domain_allowed(email)

# 不好的示例
def validate_email(email):
    if email:
        if '@' in email:
            if '.' in email.split('@')[1]:
                # 深层嵌套...
                pass
```

#### 3. 注释原则

- 优先写自解释的代码，而不是依赖注释
- 对复杂逻辑添加必要的注释说明
- 保持注释与代码同步更新
- 使用文档字符串（docstring）说明函数用途、参数和返回值

```javascript
/**
 * 计算用户的会员等级折扣
 * @param {number} memberLevel - 会员等级 (1-5)
 * @param {number} originalPrice - 原价
 * @returns {number} 折扣后的价格
 */
function calculateDiscount(memberLevel, originalPrice) {
  const discountRate = DISCOUNT_RATES[memberLevel];
  return originalPrice * discountRate;
}
```

### 版本控制

#### 1. Git 提交规范

- 使用清晰的提交信息，遵循约定式提交（Conventional Commits）
- 提交信息格式：`<类型>: <描述>`

```bash
# 提交类型
feat: 新功能
fix: 修复 bug
docs: 文档更新
style: 代码格式调整（不影响功能）
refactor: 重构
test: 测试相关
chore: 构建过程或辅助工具的变动

# 示例
git commit -m "feat: 添加用户登录功能"
git commit -m "fix: 修复注册页面验证码不显示的问题"
git commit -m "docs: 更新 API 文档"
```

#### 2. 分支管理策略

- **主分支（main/master）**：保持稳定，只包含经过测试的代码
- **开发分支（develop）**：日常开发的主分支
- **功能分支（feature/*）**：开发新功能时创建
- **修复分支（hotfix/*）**：紧急修复生产环境问题
- **发布分支（release/*）**：准备发布新版本

```bash
# 创建功能分支
git checkout -b feature/user-authentication

# 创建修复分支
git checkout -b hotfix/login-bug

# 合并后删除分支
git branch -d feature/user-authentication
```

#### 3. 合并策略

- 功能开发完成后，创建 Pull Request 进行代码审查
- 使用 Squash and Merge 保持主分支历史清晰
- 定期将主分支的更新合并到开发分支

### 协作开发

#### 1. 代码所有权

- 避免"单人拥有"的代码，鼓励知识共享
- 每个模块至少有两名开发者熟悉
- 定期进行代码走查（Code Walkthrough）

#### 2. 沟通协作

- 重要的架构决策应该团队讨论
- 使用项目管理工具（如 Jira、Trello）跟踪任务
- 及时同步进度，避免重复工作

#### 3. 代码复用

- 建立公共组件库
- 避免复制粘贴代码
- 使用包管理器管理共享代码

### 代码审查

#### 1. 审查清单

- [ ] 代码是否符合项目规范
- [ ] 逻辑是否正确，有无潜在 bug
- [ ] 是否有足够的测试覆盖
- [ ] 性能是否满足要求
- [ ] 安全性是否考虑周全
- [ ] 代码是否易于理解和维护

#### 2. 审查建议

- 保持建设性和尊重的态度
- 关注代码本身，而非个人
- 及时回复审查意见
- 小批量提交，便于审查

```markdown
# 好的审查评论
建议使用 Map 代替对象查找，可以提高性能

# 不好的审查评论
这段代码写得太烂了
```

### 测试策略

#### 1. 测试金字塔

- **单元测试（70%）**：测试单个函数或类
- **集成测试（20%）**：测试模块间的交互
- **端到端测试（10%）**：测试完整的用户流程

#### 2. 测试原则

- 测试应该快速、可重复、独立
- 每个测试只验证一个行为
- 使用有意义的测试名称
- 测试覆盖率建议达到 80% 以上

```javascript
// 好的测试示例
describe('UserService', () => {
  describe('createUser', () => {
    it('should create user with valid data', async () => {
      const userData = { name: 'John', email: 'john@example.com' };
      const user = await userService.createUser(userData);
      expect(user.id).toBeDefined();
      expect(user.name).toBe('John');
    });

    it('should throw error when email is invalid', async () => {
      const userData = { name: 'John', email: 'invalid-email' };
      await expect(userService.createUser(userData)).rejects.toThrow();
    });
  });
});
```

#### 3. 测试驱动开发（TDD）

- 先写测试，再写实现代码
- 保持测试简单明了
- 频繁运行测试

### 文档管理

#### 1. 必备文档

- **README.md**：项目介绍、安装和运行说明
- **CONTRIBUTING.md**：贡献指南
- **CHANGELOG.md**：版本更新记录
- **API 文档**：接口说明和示例

#### 2. 文档原则

- 保持文档更新，与代码同步
- 使用清晰的语言和示例
- 包含常见问题和解决方案
- 适当使用图表说明复杂流程

#### 3. 代码内文档

- 为公共 API 编写详细的文档注释
- 使用工具自动生成 API 文档（如 JSDoc、Sphinx、Javadoc）

### 性能优化

#### 1. 性能监控

- 使用性能分析工具识别瓶颈
- 设置性能基准和目标
- 定期进行性能测试

#### 2. 优化策略

- **数据库优化**：
  - 添加适当的索引
  - 避免 N+1 查询问题
  - 使用缓存减少数据库访问
  
- **前端优化**：
  - 代码分割和懒加载
  - 压缩静态资源
  - 使用 CDN 加速
  
- **后端优化**：
  - 异步处理耗时操作
  - 使用连接池
  - 实施限流和熔断机制

```javascript
// 数据库查询优化示例
// 不好的做法 - N+1 查询
const users = await User.findAll();
for (const user of users) {
  user.posts = await Post.findByUserId(user.id);
}

// 好的做法 - 使用关联查询
const users = await User.findAll({
  include: [Post]
});
```

### 安全性

#### 1. 输入验证

- 永远不要信任用户输入
- 进行数据类型和格式验证
- 防止 SQL 注入、XSS 攻击

```javascript
// 防止 XSS 攻击
function sanitizeInput(input) {
  return input
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#x27;');
}
```

#### 2. 敏感信息保护

- 不要在代码中硬编码密钥、密码
- 使用环境变量管理敏感配置
- 实施适当的访问控制

```bash
# 使用 .env 文件（不提交到版本控制）
DATABASE_URL=postgresql://user:password@localhost/db
API_KEY=your-secret-api-key
```

#### 3. 安全编码

- 使用参数化查询防止 SQL 注入
- 实施 HTTPS 加密传输
- 定期更新依赖包，修复安全漏洞
- 实施适当的身份验证和授权

---

## 注意事项

### 常见陷阱

#### 1. 过度设计

- ❌ 不要过早优化
- ❌ 避免过度抽象
- ✅ 从简单开始，根据需求逐步演进
- ✅ 遵循 YAGNI 原则（You Aren't Gonna Need It）

#### 2. 忽视错误处理

```javascript
// 不好的做法
const data = JSON.parse(userInput);

// 好的做法
try {
  const data = JSON.parse(userInput);
} catch (error) {
  console.error('Invalid JSON input:', error);
  return { error: 'Invalid data format' };
}
```

#### 3. 硬编码值

```python
# 不好的做法
if user.role == 'admin':
    pass

# 好的做法
ADMIN_ROLE = 'admin'
if user.role == ADMIN_ROLE:
    pass
```

#### 4. 忽略边界条件

- 考虑空值、null、undefined 情况
- 处理数组越界
- 验证数值范围

### 环境配置

#### 1. 环境分离

- **开发环境（Development）**：开发和调试
- **测试环境（Staging）**：测试和验证
- **生产环境（Production）**：实际运行

#### 2. 配置管理

```javascript
// config.js
const config = {
  development: {
    apiUrl: 'http://localhost:3000',
    debug: true
  },
  production: {
    apiUrl: 'https://api.example.com',
    debug: false
  }
};

export default config[process.env.NODE_ENV || 'development'];
```

#### 3. 环境变量

- 使用 `.env` 文件管理本地配置
- 确保 `.env` 文件不被提交到版本控制
- 提供 `.env.example` 作为模板

```bash
# .gitignore
.env
.env.local

# .env.example
DATABASE_URL=
API_KEY=
PORT=3000
```

### 依赖管理

#### 1. 版本锁定

- 使用 `package-lock.json`（npm）或 `yarn.lock`（Yarn）
- 定期更新依赖，但要谨慎测试
- 避免使用 `*` 或 `^` 版本号用于生产环境

#### 2. 依赖审查

- 定期检查依赖包的安全性
- 使用 `npm audit` 或 `yarn audit` 检查漏洞
- 移除不再使用的依赖

```bash
# 检查安全漏洞
npm audit

# 自动修复
npm audit fix

# 更新依赖
npm update
```

#### 3. 依赖最小化

- 只安装必要的依赖
- 考虑依赖包的大小和性能影响
- 优先使用轻量级的替代方案

### 错误处理

#### 1. 错误分类

- **预期错误**：用户输入错误、网络超时等
- **系统错误**：代码 bug、资源不足等

#### 2. 错误处理策略

```javascript
// 统一的错误处理
class AppError extends Error {
  constructor(message, statusCode) {
    super(message);
    this.statusCode = statusCode;
    this.isOperational = true;
  }
}

// 使用
if (!user) {
  throw new AppError('User not found', 404);
}

// 全局错误处理中间件
app.use((error, req, res, next) => {
  if (error.isOperational) {
    res.status(error.statusCode).json({
      status: 'error',
      message: error.message
    });
  } else {
    console.error('Unexpected error:', error);
    res.status(500).json({
      status: 'error',
      message: 'Internal server error'
    });
  }
});
```

#### 3. 日志记录

- 记录错误的详细信息
- 使用日志级别（debug、info、warn、error）
- 在生产环境关闭 debug 日志

```javascript
const logger = require('winston');

logger.error('Database connection failed', {
  error: error.message,
  stack: error.stack,
  timestamp: new Date().toISOString()
});
```

---

## 工作流程建议

### 日常开发流程

1. **开始新功能**
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/new-feature
   ```

2. **编写代码**
   - 遵循代码规范
   - 编写单元测试
   - 本地验证功能

3. **提交代码**
   ```bash
   git add .
   git commit -m "feat: 添加新功能描述"
   git push origin feature/new-feature
   ```

4. **创建 Pull Request**
   - 填写清晰的 PR 描述
   - 关联相关的 Issue
   - 等待代码审查

5. **代码审查**
   - 响应审查意见
   - 修改代码
   - 重新提交

6. **合并代码**
   - 审查通过后合并
   - 删除功能分支
   - 更新本地仓库

### 发布流程

1. **创建发布分支**
   ```bash
   git checkout -b release/v1.0.0
   ```

2. **更新版本号和文档**
   - 更新 `package.json` 版本号
   - 更新 `CHANGELOG.md`
   - 更新相关文档

3. **测试验证**
   - 运行完整测试套件
   - 手动测试关键功能
   - 性能测试

4. **合并和打标签**
   ```bash
   git checkout main
   git merge release/v1.0.0
   git tag -a v1.0.0 -m "Release version 1.0.0"
   git push origin main --tags
   ```

5. **部署**
   - 部署到生产环境
   - 监控应用状态
   - 准备回滚方案

---

## 常见问题解答

### Q1: 如何处理合并冲突？

**A:** 
1. 拉取最新的主分支代码
2. 合并到当前分支
3. 手动解决冲突
4. 测试确保功能正常
5. 提交合并结果

```bash
git checkout feature/my-feature
git pull origin develop
# 解决冲突
git add .
git commit -m "chore: 解决合并冲突"
```

### Q2: 代码审查时发现大量问题怎么办？

**A:** 
- 不要沮丧，这是学习的机会
- 逐一理解和修复问题
- 记录常见错误，避免重复
- 必要时可以重新设计方案

### Q3: 如何提高代码质量？

**A:**
- 持续学习，阅读优秀代码
- 积极参与代码审查
- 使用代码质量工具（如 ESLint、SonarQube）
- 重构已有代码
- 编写测试

### Q4: 遇到性能问题如何排查？

**A:**
1. 使用性能分析工具定位瓶颈
2. 检查数据库查询效率
3. 分析算法时间复杂度
4. 查看网络请求
5. 监控内存使用

### Q5: 如何处理紧急 bug？

**A:**
1. 评估影响范围和严重程度
2. 创建 hotfix 分支
3. 快速定位和修复问题
4. 编写测试防止回归
5. 尽快发布修复版本
6. 事后分析，防止类似问题

```bash
git checkout main
git checkout -b hotfix/critical-bug
# 修复问题
git commit -m "fix: 修复关键 bug"
# 合并回主分支和开发分支
```

### Q6: 如何管理技术债务？

**A:**
- 记录技术债务清单
- 定期分配时间偿还技术债
- 在每个迭代中包含重构任务
- 避免"临时方案"变成永久方案
- 重大重构前做好规划

---

## 总结

遵循这些最佳实践和注意事项，可以帮助团队：
- ✅ 提高代码质量和可维护性
- ✅ 减少 bug 和安全问题
- ✅ 提升开发效率
- ✅ 促进团队协作
- ✅ 建立良好的开发文化

记住，最佳实践不是一成不变的，要根据项目和团队的实际情况灵活调整。持续学习和改进是保持竞争力的关键。

---

## 参考资源

- [Git 官方文档](https://git-scm.com/doc)
- [代码整洁之道](https://github.com/ryanmcdermott/clean-code-javascript)
- [约定式提交](https://www.conventionalcommits.org/)
- [测试金字塔](https://martinfowler.com/articles/practical-test-pyramid.html)
- [12-Factor App](https://12factor.net/)

---

*最后更新日期：2026-02-03*
