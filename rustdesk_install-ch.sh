#!/bin/bash
# RustDesk Server 一键安装脚本

set -e

# 更新系统并安装依赖
echo "更新系统并安装依赖..."
sudo apt update
sudo apt install -y curl openssl

# 使用清华大学镜像下载 RustDesk 服务器组件
echo "使用清华大学镜像下载 RustDesk 服务器组件"
curl -L -o hbbs https://mirrors.tuna.tsinghua.edu.cn/github-release/rustdesk/rustdesk-server/latest/download/hbbs
curl -L -o hbbr https://mirrors.tuna.tsinghua.edu.cn/github-release/rustdesk/rustdesk-server/latest/download/hbbr

# 将组件移动到系统路径并赋予可执行权限
if [[ -f "hbbs" && -f "hbbr" ]]; then
    echo "下载完成，移动 RustDesk 服务器组件..."
    sudo mv hbbs /usr/local/bin/
    sudo mv hbbr /usr/local/bin/
    sudo chmod +x /usr/local/bin/hbbs /usr/local/bin/hbbr
else
    echo "下载失败，请检查网络连接或镜像源。"
    exit 1
fi

# 创建密钥目录并生成 ed25519 密钥文件
if [[ ! -f "/root/.config/rustdesk/id_ed25519" ]]; then
    echo "生成 ed25519 密钥文件..."
    sudo mkdir -p /root/.config/rustdesk
    sudo ssh-keygen -t ed25519 -f /root/.config/rustdesk/id_ed25519 -N ""
else
    echo "ed25519 密钥文件已存在，跳过生成。"
fi

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
sudo systemctl status hbbs --no-pager -l
sudo systemctl status hbbr --no-pager -l

# 获取服务器公网 IP 地址
server_ip=$(curl -s https://ifconfig.me)

# 输出服务器详细信息
echo "--------------------------------------"
echo "RustDesk 服务器安装完成！"
echo "服务器信息："
echo "服务器公网地址: $server_ip"
echo "服务器端口 (默认): 21116"
echo "公钥内容 (复制到客户端以便连接到此服务器)："
cat /root/.config/rustdesk/id_ed25519.pub
echo "--------------------------------------"
