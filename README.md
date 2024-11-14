# RustDesk 服务器一键安装脚本

### 国内服务器（无法访问 GitHub）国内下载源是自己在国内gitee上传的文件，如果需要新版本要到github下载和修改脚本里的文件名
```bash
curl -fsSL https://raw.githubusercontent.com/LD-Bao/RustDesk/refs/heads/main/rustdesk_install-ch.sh | bash
```

### 国外服务器（可以访问 GitHub）自动下载最新版本安装
```bash
curl -fsSL https://raw.githubusercontent.com/LD-Bao/RustDesk/refs/heads/main/rustdesk_install.sh | bash
```

---

# RustDesk 服务器手动安装流程

## 客户端软件下载
前往 [RustDesk 发布页面](https://github.com/rustdesk/rustdesk/releases/tag/1.3.2) 下载对应操作系统的 RustDesk 客户端文件：
- Windows 系统下载 EXE 文件
- 安卓手机可以选择 Universal 版本

## 服务器组件下载
1. 前往 [RustDesk 服务器 GitHub 页面](https://github.com/rustdesk/rustdesk-server) 获取最新版本的服务器组件。
2. 下载 `hbbs` 和 `hbbr` 的 `amd64.deb` 文件，下载到本地并上传至服务器的指定目录。

## 安装服务器组件
在服务器中，将已上传的 `deb` 文件安装至系统。假设文件在 `/usr/local/bin` 目录下，使用以下命令安装（根据实际路径调整）：

```bash
sudo dpkg -i /usr/local/bin/rustdesk-server-hbbs_1.1.12_amd64.deb
sudo dpkg -i /usr/local/bin/rustdesk-server-hbbr_1.1.12_amd64.deb
```

安装完成后，RustDesk 服务器的可执行文件通常位于 `/usr/local/bin` 或 `/usr/bin`。使用以下命令确认安装路径：

```bash
which hbbs
which hbbr
```

## 启用并启动服务
启用和启动 `hbbs` 和 `hbbr` 服务，以确保它们在系统启动时自动运行：

```bash
sudo systemctl daemon-reload
sudo systemctl enable rustdesk-hbbs
sudo systemctl start rustdesk-hbbs
sudo systemctl enable rustdesk-hbbr
sudo systemctl start rustdesk-hbbr
```

## 检查服务状态
确认 `hbbs` 和 `hbbr` 服务是否正常运行：

```bash
sudo systemctl status rustdesk-hbbs
sudo systemctl status rustdesk-hbbr
```

## 查找密钥
服务启动后，密钥文件通常会自动生成于 `/var/lib/rustdesk-server/id_ed25519.pub` 路径下。如无法找到此文件，可以使用以下命令搜索：

```bash
sudo find / -name "id_ed25*" 2>/dev/null
```

## 客户端设置
在 RustDesk 客户端中进行以下配置：
1. 点击**设置** > **网络**。
2. 在 **ID服务器** 和 **中继服务器** 中填写搭建的 RustDesk 服务器的 IP 地址。
3. 在 **密钥** 栏中粘贴找到的公钥内容（即 `id_ed25519.pub` 文件的内容）。

---

复制以上流程到 GitHub 后，用户即可使用一键安装脚本或手动配置 RustDesk 服务器。
