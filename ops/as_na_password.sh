#!/bin/bash
NAPCAT_NAME="napcat"          
ASTRBOT_NAME="astrbot"        
OUTPUT_FILE="/opt/astrbot/as_na_passwork.txt"  # 输出保存文件路径
HEAD_NUM=500 

> "${OUTPUT_FILE}"

echo "==== Napcat Token ====" >> "${OUTPUT_FILE}"
docker logs ${NAPCAT_NAME} 2>&1 | head -n ${HEAD_NUM} | grep -i token | awk -F'=' '{print $2}' >> "${OUTPUT_FILE}"

echo -e "\n==== AstrBot 账号信息 ====" >> "${OUTPUT_FILE}"
docker logs ${ASTRBOT_NAME} 2>&1 | head -n ${HEAD_NUM} | grep -i "Username" | awk -F':' '{print $2}' >> "${OUTPUT_FILE}"
docker logs ${ASTRBOT_NAME} 2>&1 | head -n ${HEAD_NUM} | grep -i "Userpassword" | awk -F':' '{print $2}' >> "${OUTPUT_FILE}"

echo "完成，结果保存到 ${OUTPUT_FILE}"

