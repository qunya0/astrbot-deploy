#!/bin/bash
do_name="napcat"
max_count_ws=5
email="/opt/ops/email.sh"

#收件人邮箱
email_to=""
email_ws="Napcat WebSocket反向连接异常告警"
email_kick="Napcat账号离线紧急告警"

count_ws=0

log_head_er='\[error\]'
log_head_in='\[info\]'
log_ws_body='反向WebSocket.*连接意外关闭'
log_kick_body='\[KickedOffLine\].*下线通知'
log_line_body='账号状态变更为离线'

check_line(){
	local line="$1"
	if [[ $line =~ $log_head_er && $line =~ $log_ws_body ]]; then
		echo "ws"
		return
	fi
	if [[ $line =~ $log_head_in && $line =~ $log_line_body ]]; then
		if [[ ! $line =~ 接受 && ! $line =~ 发送 ]]; then
                	echo "line"
                	return
		fi
        fi
	if [[ $line =~ $log_head_er && $line =~ $log_kick_body ]]; then
                echo "kick"
                return
        fi
	echo "none"
}

docker logs -f "${do_name}" 2>&1 | while read -r line
do
	res=$(check_line "$line")
    case "${res}" in
        "kick")
            bash "${email}" "${email_to}" "${email_kick}" "Napcat检测到账号被踢下线,日志内容：${line}"
            count_ws=0
            ;;
        "line")
            bash "${email}" "${email_to}" "${email_kick}" "Napcat账号状态变更为离线！日志内容：${line}"
            count_ws=0
            ;;
        "ws")
            count_ws=$((count_ws + 1))
            if [[ ${count_ws} -ge ${max_count_ws} ]]; then
                bash "${email}" "${email_to}" "${email_ws}" "Napcat连续${max_count_ws}次WebSocket反向连接关闭！日志内容：${line}"
                count_ws=0
            fi
            ;;
        "none")
            count_ws=0
            ;;
    esac
done
