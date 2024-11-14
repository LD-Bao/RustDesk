#!/bin/bash
# RustDesk Server 一键安装脚本（适用于可以访问 GitHub 的国外服务器）

set -e

# 更新系统并安装依赖
echo "更新系统并安装依赖..."
sudo apt update
sudo apt install -y curl openssl

# 获取 RustDesk 服务器最新版本的文件链接
echo "获取 RustDesk 服务器最新版本信息..."
latest_version=$(curl -s https://api.github.com/repos/rustdesk/rustdesk-server/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
hbbs_url="https://github.com/rustdesk/rustdesk-server/releases/download/$latest_version/rustdesk-server-hbbs_${latest_version}_amd64.deb"
hbbr_url="https://github.com/rustdesk/rustdesk-server/releases/download/$latest_version/rustdesk-server-hbbr_${latest_version}_amd64.deb"

# 下载 RustDesk 服务器组件
echo "下载 RustDesk 服务器组件：$latest_version"
curl -L -o rustdesk-server-hbbs.deb "$hbbs_url"
curl -L -o rustdesk-server-hbbr.deb "$hbbr_url"

# 检查是否成功下载
if [[ ! -f "rustdesk-server-hbbs.deb" || ! -f "rustdesk-server-hbbr.deb" ]]; then
    echo "下载失败，请检查网络连接或链接是否有效。"
    exit 1
fi

# 安装 RustDesk 服务器组件
echo "安装 RustDesk 服务器组件..."
sudo dpkg -i rustdesk-server-hbbs.deb
sudo dpkg -i rustdesk-server-hbbr.deb

# 启动并启用服务
echo "启动并启用 RustDesk 服务..."
sudo systemctl enable rustdesk-hbbs rustdesk-hbbr
sudo systemctl start rustdesk-hbbs rustdesk-hbbr

# 等待密钥生成
echo "等待 RustDesk 自动生成密钥文件..."
sleep 5  # 等待一会，确保密钥文件生成

# 检查密钥文件是否生成
if [[ -f "/var/lib/rustdesk-server/id_ed25519.pub" ]]; then
    echo "密钥文件已生成。"
else
    echo "密钥文件未生成，请检查服务状态。"
    exit 1
fi

# 获取服务器公网 IP 地址
server_ip=$(curl -s https://ifconfig.me)

# 输出服务器详细信息
echo "--------------------------------------"
echo "RustDesk 服务器安装完成！"
echo "服务器信息："
echo "服务器公网地址: $server_ip"
echo "服务器端口 (默认): 21116"
echo "公钥内容 (复制到客户端以便连接到此服务器)："
cat /var/lib/rustdesk-server/id_ed25519.pub
echo "--------------------------------------"
