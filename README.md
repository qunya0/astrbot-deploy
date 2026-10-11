AstrBot 部署配置

基于 2 核 2G 阿里云服务器的 AstrBot 推荐部署配置

本项目提供一套 Docker Compose 编排方案，用于在阿里云 2 核 2G 服务器上部署 AstrBot + NapCat QQ 机器人，包含 Nginx 反向代理、Postfix 邮件服务，以及 AstrBot 资源监控和 NapCat 断联邮件告警功能。

项目结构

```
astrbot-deploy/
├── astrbot/
│   └── astrbot.yml            # AstrBot + NapCat 容器编排
├── nginx/
│   ├── html/                   # Nginx 主页面
│   ├── astrbot.conf            # Nginx 节点跳转配置
│   ├── cd_volunes.sh           # 配置更改脚本
│   └── nginx.yml               # Nginx 容器编排
├── ops/
│   ├── logs/                   # 日志目录
│   ├── service/                # systemd 服务单元
│   ├── as_na_password.sh       # 查看 NapCat Token / AstrBot 初始账号密码
│   ├── astr_use.sh             # AstrBot 资源监控脚本
│   ├── email.sh                # 邮件发送封装脚本
│   ├── init_astr_nap.sh        # 初始化邮箱配置脚本
│   ├── napcat_connect.sh       # NapCat 断联检测与告警脚本
│   └── re_service.sh           # 服务单元启动脚本
├── postfix/
│   ├── .env                    # Postfix 环境变量配置
│   ├── postfix.yml             # Postfix 容器编排
│   └── postfix_init.sh         # Postfix 初始化.env脚本
└── README.md
```

前情提要

1. 本项目的所有脚本均采用绝对路径，请务必将此项目安置在 /opt 目录下。
2. 请确保服务器上已安装 Docker，并支持 awk 和 bc 命令。
3. 编排中启用了 swap 交换分区，2G 内存服务器建议开启。
4. 推荐使用 QQ 密码登录而非扫码登录，以解决 NapCat QQ 频繁掉线问题。

检测步骤

1. 检查 Docker 环境

```bash
docker --version
docker compose version
```

2. 检查依赖命令

```bash
which awk bc
```

若未安装：

```bash
# Debian / Ubuntu
sudo apt update && sudo apt install -y gawk bc

# CentOS / Alibaba Cloud Linux
sudo yum install -y gawk bc
```

3. 检查 swap 状态

```bash
free -mh
swapon --show
```

4. 开启 swap 交换分区

```bash
# 1. 创建 2G 交换文件
sudo dd if=/dev/zero of=/swapfile bs=1M count=2048

# 2. 设置权限
sudo chmod 600 /swapfile

# 3. 格式化交换文件
sudo mkswap /swapfile

# 4. 启用交换分区
sudo swapon /swapfile

# 5. 永久生效
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# 6. 验证
free -mh
swapon --show
```

注意事项

· 项目配置了默认的 Nginx 主页面（nginx/html），并提供了推荐的节点跳转配置（nginx/astrbot.conf），同时提供了方便更改配置的脚本（nginx/cd_volunes.sh）。  
· 因为配置了 Postfix，此项目需要收集你的邮箱和授权码。/postfix/postfix_init.sh 提供了简单的初始化配置脚本。

开始步骤
