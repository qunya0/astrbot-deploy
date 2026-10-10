#!/bin/bash
echo "初始化配置。添加信任网段(默认astrbot_network)"
asnet=$(docker network inspect astrbot_network | awk -F'"' '/Subnet/{print $4}')
awk -v net="$asnet" '/MYNETWORKS=/{$0="MYNETWORKS=" net}1' .env > tmp.env && mv tmp.env .env
echo "输入你的qq邮箱"
read qq_com
awk -v net="$qq_com" '/RELAYHOST_USERNAME=/{$0="RELAYHOST_USERNAME=" net}1' .env > tmp.env && mv tmp.env .env
echo "输入你的qq邮箱授权码"
read qq_
awk -v net="$qq_" '/RELAYHOST_PASSWORD=/{$0="RELAYHOST_PASSWORD=" net}1' .env > tmp.env && mv tmp.env .env
cat .env
chmod 600 /opt/postfix/.env
