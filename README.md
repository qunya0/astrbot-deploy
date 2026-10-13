# AstrBot 部署配置
基于 2 核 2G 阿里云服务器的 AstrBot 推荐部署配置

本项目提供一套 Docker Compose 编排方案，用于在阿里云 2 核 2G 服务器上部署 AstrBot + NapCat QQ 机器人，包含 Nginx 反向代理、Postfix 邮件服务，以及 AstrBot 资源监控和 NapCat 断联邮件告警功能。

## 项目结构
```markdow
astrbot-deploy/  
├── astrbot/  
│   ├── astrbot.yml            # AstrBot + NapCat 容器编排  
│   └── as_na_passwork.txt     # AstrBot + NapCat 初始用户名、密码、Token存储  
├── nginx/    
│   ├── html/                   # Nginx 主页面  
│   ├── astrbot.conf            # Nginx 节点跳转配置  
│   ├── cd_volunes.sh           # 配置更改脚本  
│   └── nginx.yml               # Nginx 容器编排  
├── ops/  
│   ├── logs/                   # 日志目录  
│   ├── service/                # systemd 服务单元文件目录  
│   ├── as_na_password.sh       # 查看 NapCat Token / AstrBot 初始账号密码  
│   ├── astr_use.sh             # AstrBot 资源监控脚本  
│   ├── email.sh                # 邮件发送封装脚本  
│   ├── init_astr_nap.sh        # 初始化邮箱配置脚本  
│   ├── napcat_connect.sh       # NapCat 断联检测与告警脚本  
│   └── re_service.sh           # 注册 systemd 服务单元脚本  
├── postfix/  
│   ├── .env                    # Postfix 环境变量配置  
│   ├── postfix.yml             # Postfix 容器编排  
│   └── postfix_init.sh         # Postfix 初始化 .env 脚本  
└── README.md  
```

## 前情提要
1. 本项目所有脚本使用**绝对路径**，务必将项目放置在 `/opt` 目录下。
2. 服务器提前安装 Docker、Docker Compose；脚本依赖 `awk`、`bc`。
3. 2G内存服务器建议开启 swap 交换分区，缓解内存溢出。
4. NapCat 推荐 QQ 密码登录，相比扫码登录稳定性更高，减少掉线。

## 前置检测步骤
### 1. 检查 Docker 环境
```bash
docker --version
docker compose version
```

### 2. 检查依赖命令
```bash
which awk bc
```
缺少则安装：
```bash
# Debian / Ubuntu
apt update && apt install -y gawk bc

# CentOS / Alibaba Cloud Linux
yum install -y gawk bc
```

### 3. 检查 swap 状态
```bash
free -mh
swapon --show
```

### 4. 开启 swap 交换分区（2G）
> 部分阿里云实例内核/磁盘类型不支持 swap，开启失败可跳过
```bash
# 1. 创建 2G 交换文件
dd if=/dev/zero of=/swapfile bs=1M count=2048
# 2. 设置权限
chmod 600 /swapfile
# 3. 格式化交换文件
mkswap /swapfile
# 4. 启用交换分区
swapon /swapfile
# 5. 写入 fstab 开机自动挂载
echo '/swapfile none swap sw 0 0' | tee -a /etc/fstab
# 6. 验证
free -mh
swapon --show
```

## 注意事项
- Nginx 默认静态页面放在 `nginx/html`，反向代理配置 `astrbot.conf` 用于 AstrBot 节点转发；配套 `cd_volunes.sh` 方便批量修改挂载配置。
- Postfix 邮件服务需要你的邮箱账号+授权码，通过 `postfix/postfix_init.sh` 交互式写入 `.env`。
- 所有 `.sh` 脚本执行前必须赋予执行权限。

## 部署步骤
```bash
# 给所有脚本添加执行权限
find /opt -type f -name "*.sh" -exec chmod +x {} \;

# 1. 启动 Nginx、AstrBot + NapCat 容器
docker compose -f /opt/nginx/nginx.yml up -d
docker compose -f /opt/astrbot/astrbot.yml up -d

# 2. 初始化 Postfix 配置并启动邮件容器
/opt/postfix/postfix_init.sh
docker compose -f /opt/postfix/postfix.yml up -d

# 3. 部署 Nginx 站点配置并重载生效
cp /opt/nginx/astrbot.conf /var/lib/docker/volumes/ngconf/_data/conf.d/
docker compose -f /opt/nginx/nginx.yml reload

# 4. 初始化邮箱告警配置
/opt/ops/init_astr_nap.sh

# 5. 获取 NapCat Token、AstrBot 初始账号密码
/opt/ops/as_na_passwork.sh

# 6. 注册并启用 systemd 监控服务（断联告警、资源监控）
/opt/ops/re_service.sh
```

## 部署后验证
```bash
# 查看容器运行状态
docker ps
# 查看 systemd 监控服务状态
systemctl status astrbot-monitor
# 查看监控日志
journalctl -u astrbot-monitor -f
```
访问 Nginx 地址，验证 AstrBot Web 面板是否正常打开；触发一次测试邮件，确认告警通道可用。
