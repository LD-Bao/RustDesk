#!/bin/bash
# RustDesk Server 一键安装脚本

set -e

# 更新系统并安装依赖
echo "更新系统并安装依赖..."
sudo apt update
sudo apt install -y curl openssl

# 获取最新版本的下载链接
echo "正在获取 RustDesk 最新版本信息..."
latest_version=$(curl -s https://api.github.com/repos/rustdesk/rustdesk-server/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
hbbs_url="https://github.com/rustdesk/rustdesk-server/releases/download/$latest_version/hbbs"
hbbr_url="https://github.com/rustdesk/rustdesk-server/releases/download/$latest_version/hbbr"

# 下载最新的 RustDesk 服务器组件
echo "下载最新版本的 RustDesk 服务器组件：$latest_version"
curl -L -o hbbs $hbbs_url
curl -L -o hbbr $hbbr_url

# 将组件移动到系统路径并赋予可执行权限
sudo mv hbbs /usr/local/bin/
sudo mv hbbr /usr/local/bin/
sudo chmod +x /usr/local/bin/hbbs /usr/local/bin/hbbr

# 创建密钥目录并生成密钥文件
echo "生成密钥文件..."
sudo mkdir -p /etc/rustdesk
openssl genrsa -out /etc/rustdesk/hbbs.key 2048
openssl rsa -in /etc/rustdesk/hbbs.key -pubout -out /etc/rustdesk/hbbs.pub

# 创建 hbbs 服务文件
echo "创建 hbbs 服务文件..."
sudo tee /etc/systemd/system/hbbs.service > /dev/null <<EOF
[Unit]
Description=RustDesk HBBS Server
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/hbbs -k /etc/rustdesk/hbbs.key
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# 创建 hbbr 服务文件
echo "创建 hbbr 服务文件..."
sudo tee /etc/systemd/system/hbbr.service > /dev/null <<EOF
[Unit]
Description=RustDesk HBBR Server
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/hbbr
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# 重新加载 systemd 服务并启动 hbbs 和 hbbr
echo "启动并启用 RustDesk 服务..."
sudo systemctl daemon-reload
sudo systemctl enable hbbs hbbr
sudo systemctl start hbbs hbbr

# 验证服务状态
echo "验证 RustDesk 服务状态..."
sudo systemctl status hbbs --no-pager
sudo systemctl status hbbr --no-pager

# 获取服务器IP地址
server_ip=$(hostname -I | awk '{print $1}')

# 输出服务器详细信息
echo "--------------------------------------"
echo "RustDesk 服务器安装完成！"
echo "服务器信息："
echo "服务器地址: $server_ip"
echo "服务器端口 (默认): 21116"
echo "公钥内容 (复制到客户端以便连接到此服务器)："
cat /etc/rustdesk/hbbs.pub
echo "--------------------------------------"
