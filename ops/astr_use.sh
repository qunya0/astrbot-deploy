#!/bin/bash
do_name="astrbot"
max_limit=90
max_count=7
check_sleep=60
log_file="/opt/ops/logs/astrbot_use.log"
count=0

email="/opt/ops/email.sh"
#收件人邮箱
email_to=""
email_astr="astrbot资源超限警告"


log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "${log_file}"
}
log "==== ${do_name}监控脚本启动 ===="
log "容器: ${do_name}, 阈值:${max_limit}%, 连续${max_count}次超限将重启"
while true; do
run_stats=$(docker inspect --format '{{.State.Running}}' "${do_name}" 2>/dev/null)
if [[ "${run_stats}" != "true" ]]; then
    count=$((count + 1))
    log "容器未运行！累计异常次数: ${count}"
    if [[ ${count} -ge ${max_count} ]]; then
        log "累计${max_count}次异常，执行容器重启"
        docker restart "${do_name}"
        log "重启命令已执行，重置计数器"
        count=0
    fi
    sleep ${check_sleep}
    continue
fi
nano_cpus=$(docker inspect --format '{{.HostConfig.NanoCpus}}' "${do_name}")
cpu_quota=$(echo "scale=3; ${nano_cpus}/1000000000" | bc)
stats=$(docker stats --no-stream --format '{{.CPUPerc}} {{.MemPerc}}' "${do_name}")
cpu_host=$(echo "${stats}" | awk '{print $1}' | tr -d '%')
mem_limit=$(echo "${stats}" | awk '{print $2}' | tr -d '%')
cpu_limit=$(echo "scale=2; ${cpu_host} / ${cpu_quota}" | bc)
log_info="整机CPU:${cpu_host}% | CPU配额占比:${cpu_limit}% | 内存限额占比:${mem_limit}% | 容器配额${cpu_quota}核"
over_cpu=$(echo "${cpu_limit} > ${max_limit}" | bc)
over_mem=$(echo "${mem_limit} > ${max_limit}" | bc)

if [[ ${over_cpu} -eq 1 || ${over_mem} -eq 1 ]]; then
    count=$((count +1))
    log "资源超限${log_info} | 累计异常次数:${count}"
    if [[ ${count} -ge ${max_count} ]]; then
        log "累计${max_count}次异常，执行容器重启"
        docker restart "${do_name}"
        log "重启命令已执行，重置计数器"
	bash "${email}" "${email_to}" "${email_astr}" "资源超限${log_info},执行重启"	
        count=0
    fi
else
    count=0
    log "资源正常${log_info} | 累计异常次数:${count}"
fi
sleep ${check_sleep}
done
