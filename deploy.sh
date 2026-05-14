#!/bin/bash
# ============================================================
# MindFlow AI — 服务器一键部署脚本
# 适用: Ubuntu 22.04+, 2核2G
# ============================================================

set -e

echo "=========================================="
echo "  MindFlow AI — 服务器部署"
echo "=========================================="

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ---------- 1. 安装 Docker ----------
if ! command -v docker &> /dev/null; then
    echo "[1/5] 安装 Docker..."
    curl -fsSL https://get.docker.com | sudo bash
    sudo systemctl enable docker
    sudo systemctl start docker
else
    echo "[1/5] Docker 已安装 ✓"
fi

# ---------- 2. 当前用户 docker 权限 ----------
if ! groups | grep -q docker; then
    sudo usermod -aG docker $USER
    echo "    [!] 已添加 docker 权限，请退出重新登录后再次运行此脚本"
    exit 0
fi
echo "[2/5] Docker 权限 ✓"

# ---------- 3. 配置 .env ----------
cd "$PROJECT_DIR/docker"

if [ ! -f .env ]; then
    if [ -f "$PROJECT_DIR/.env.example" ]; then
        cp "$PROJECT_DIR/.env.example" .env
        echo "[3/5] 已从 .env.example 创建 docker/.env"
    else
        echo "    [!] 找不到 .env.example，请手动创建 docker/.env"
        exit 1
    fi
else
    echo "[3/5] docker/.env 已存在 ✓"
fi

# 检查是否修改了默认值
if grep -q "sk-your-deepseek-api-key-here" .env; then
    echo "    [!] 请先编辑 docker/.env，填入你的 AI_API_KEY"
    exit 1
fi
if grep -q "change-me-to-a-random-string" .env; then
    echo "    [!] 请先编辑 docker/.env，修改 JWT_SECRET"
    exit 1
fi

# ---------- 4. 创建 swap（防 OOM）----------
if [ ! -f /swapfile ]; then
    echo "[4/5] 创建 2GB swap..."
    sudo fallocate -l 2G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
else
    echo "[4/5] swap 已存在 ✓"
fi

# ---------- 5. 构建并启动 ----------
echo "[5/5] 构建镜像并启动容器..."
docker compose up -d --build

echo ""
echo "=========================================="
echo "  部署完成！"
echo "=========================================="
echo ""
echo "  访问地址: http://$(curl -s ifconfig.me 2>/dev/null || echo '你的服务器IP')"
echo ""
echo "  常用命令（在 docker/ 目录下执行）:"
echo "    docker compose logs -f     查看日志"
echo "    docker compose ps          查看状态"
echo "    docker compose restart     重启"
echo "    docker compose down        停止"
echo ""
