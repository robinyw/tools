# Python 项目安装部署指南

## 环境要求

- Python >= 3.8
- pip >= 20.0

## 安装步骤

### 1. 安装 Python

#### Windows
从 [Python 官网](https://www.python.org/downloads/) 下载并安装最新版本。
记得勾选 "Add Python to PATH"。

#### macOS
```bash
# 使用 Homebrew
brew install python3

# 或从官网下载
https://www.python.org/downloads/
```

#### Linux (Ubuntu/Debian)
```bash
# 安装 Python 3
sudo apt update
sudo apt install python3 python3-pip python3-venv

# 验证安装
python3 --version
pip3 --version
```

### 2. 创建虚拟环境

```bash
# 创建项目目录
mkdir my-project
cd my-project

# 创建虚拟环境
python3 -m venv venv

# 激活虚拟环境
# Linux/macOS
source venv/bin/activate

# Windows
venv\Scripts\activate

# 验证虚拟环境
which python  # Linux/macOS
where python  # Windows
```

### 3. 安装依赖

```bash
# 从 requirements.txt 安装
pip install -r requirements.txt

# 安装单个包
pip install <package-name>

# 安装开发依赖
pip install -r requirements-dev.txt

# 生成 requirements.txt
pip freeze > requirements.txt
```

## 开发环境配置

### 环境变量

创建 `.env` 文件：

```bash
FLASK_APP=app.py
FLASK_ENV=development
DEBUG=True
DATABASE_URL=postgresql://localhost/mydb
SECRET_KEY=your-secret-key
```

### 使用 python-dotenv

```python
# 安装
pip install python-dotenv

# 在代码中使用
from dotenv import load_dotenv
import os

load_dotenv()
debug = os.getenv('DEBUG')
```

### 启动开发服务器

```bash
# Flask 应用
flask run

# Django 应用
python manage.py runserver

# FastAPI 应用
uvicorn main:app --reload

# 普通 Python 脚本
python main.py
```

## 依赖管理

### 使用 pip-tools

```bash
# 安装 pip-tools
pip install pip-tools

# 创建 requirements.in
echo "flask>=2.0.0" > requirements.in

# 生成 requirements.txt
pip-compile requirements.in

# 同步依赖
pip-sync requirements.txt
```

### 使用 Poetry

```bash
# 安装 Poetry
curl -sSL https://install.python-poetry.org | python3 -

# 初始化项目
poetry init

# 添加依赖
poetry add flask

# 安装依赖
poetry install

# 激活虚拟环境
poetry shell

# 运行脚本
poetry run python main.py
```

### 使用 Pipenv

```bash
# 安装 Pipenv
pip install pipenv

# 安装依赖
pipenv install flask

# 激活虚拟环境
pipenv shell

# 运行脚本
pipenv run python main.py
```

## 构建和测试

### 运行测试

```bash
# 使用 pytest
pip install pytest
pytest

# 使用 unittest
python -m unittest discover

# 生成覆盖率报告
pip install pytest-cov
pytest --cov=.
```

### 代码质量检查

```bash
# 使用 flake8
pip install flake8
flake8 .

# 使用 pylint
pip install pylint
pylint your_module

# 使用 black 格式化
pip install black
black .

# 使用 mypy 类型检查
pip install mypy
mypy .
```

## 部署到生产环境

### 1. 准备部署

```bash
# 设置生产环境变量
export FLASK_ENV=production
export DEBUG=False

# 安装仅生产依赖
pip install -r requirements.txt --no-dev
```

### 2. 使用 Gunicorn

```bash
# 安装 Gunicorn
pip install gunicorn

# 启动应用
gunicorn -w 4 -b 0.0.0.0:8000 wsgi:app

# 使用配置文件
gunicorn -c gunicorn_config.py wsgi:app
```

示例 `gunicorn_config.py`：

```python
bind = "0.0.0.0:8000"
workers = 4
worker_class = "sync"
worker_connections = 1000
timeout = 30
keepalive = 2
```

### 3. 使用 Supervisor 进程管理

安装 Supervisor：

```bash
sudo apt install supervisor
```

配置文件 `/etc/supervisor/conf.d/myapp.conf`：

```ini
[program:myapp]
command=/path/to/venv/bin/gunicorn -c gunicorn_config.py wsgi:app
directory=/path/to/project
user=www-data
autostart=true
autorestart=true
redirect_stderr=true
stdout_logfile=/var/log/myapp.log
```

启动服务：

```bash
sudo supervisorctl reread
sudo supervisorctl update
sudo supervisorctl start myapp
```

### 4. 使用 Docker 部署

创建 `Dockerfile`：

```dockerfile
FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8000

CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:8000", "wsgi:app"]
```

创建 `docker-compose.yml`：

```yaml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "8000:8000"
    environment:
      - FLASK_ENV=production
      - DATABASE_URL=postgresql://db:5432/mydb
    depends_on:
      - db
  
  db:
    image: postgres:13
    environment:
      - POSTGRES_DB=mydb
      - POSTGRES_PASSWORD=secret
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

构建和运行：

```bash
# 构建并启动
docker-compose up -d

# 查看日志
docker-compose logs -f

# 停止服务
docker-compose down
```

## 数据库迁移

### 使用 Alembic (Flask/SQLAlchemy)

```bash
# 安装 Alembic
pip install alembic

# 初始化
alembic init alembic

# 创建迁移
alembic revision --autogenerate -m "Initial migration"

# 执行迁移
alembic upgrade head
```

### 使用 Django Migrations

```bash
# 创建迁移
python manage.py makemigrations

# 执行迁移
python manage.py migrate

# 查看迁移状态
python manage.py showmigrations
```

## 常见问题

### 包安装失败

```bash
# 升级 pip
pip install --upgrade pip

# 清除缓存
pip cache purge

# 使用国内镜像源
pip install -i https://pypi.tuna.tsinghua.edu.cn/simple <package-name>

# 配置永久镜像源
pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple
```

### 虚拟环境问题

```bash
# 删除虚拟环境
rm -rf venv

# 重新创建
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

## 最佳实践

1. 始终使用虚拟环境隔离项目依赖
2. 使用 `.gitignore` 忽略 `venv/`、`__pycache__/`、`.env`
3. 固定依赖版本以确保可重现性
4. 使用类型提示提高代码质量
5. 编写测试并保持高覆盖率
6. 使用代码格式化工具保持一致性
7. 定期更新依赖包以修复安全漏洞

## 相关资源

- [Python 官方文档](https://docs.python.org/)
- [pip 文档](https://pip.pypa.io/)
- [Poetry 文档](https://python-poetry.org/docs/)
- [Flask 文档](https://flask.palletsprojects.com/)
- [Django 文档](https://docs.djangoproject.com/)
- [FastAPI 文档](https://fastapi.tiangolo.com/)
