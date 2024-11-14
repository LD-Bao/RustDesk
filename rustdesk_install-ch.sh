#!/bin/bash
# RustDesk Server 一键安装脚本

set -e

# 更新系统并安装依赖
echo "更新系统并安装依赖..."
sudo apt update
sudo apt install -y curl openssl

# 下载 RustDesk 服务器组件
echo "下载 RustDesk 服务器组件..."
curl -L -o rustdesk-server-hbbr_1.1.12_amd64.deb https://gitee.com/LD-BAO/rust-desk/raw/master/rustdesk-server-hbbr_1.1.12_amd64.deb
curl -L -o rustdesk-server-hbbs_1.1.12_amd64.deb https://gitee.com/LD-BAO/rust-desk/raw/master/rustdesk-server-hbbs_1.1.12_amd64.deb

# 安装下载的 .deb 文件
echo "安装 RustDesk 服务器组件..."
sudo dpkg -i rustdesk-server-hbbr_1.1.12_amd64.deb
sudo dpkg -i rustdesk-server-hbbs_1.1.12_amd64.deb

# 删除下载的 .deb 文件
rm rustdesk-server-hbbr_1.1.12_amd64.deb
rm rustdesk-server-hbbs_1.1.12_amd64.deb

# 启动并启用 hbbs 和 hbbr 服务
echo "启动并启用 RustDesk 服务..."
sudo systemctl enable hbbs hbbr
sudo systemctl start hbbs hbbr

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
