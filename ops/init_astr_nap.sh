#!/bin/bash
echo "初始化 email.sh astrbot_use.sh napcat_connect.sh"
email="/opt/ops/email.sh"
astr="/opt/ops/astr_use.sh"
nap="/opt/ops/napcat_connect.sh"
echo "输入发件人，和postfix配置保持一致"
read email_host
awk -v net="$email_host" '/FROM_ADDR=""/{$0="FROM_ADDR=\"" net "\""}1' "${email}" > /tmp/tmp.email.sh && mv /tmp/tmp.email.sh "${email}"
echo "输入收件人"
read email_to
awk -v net="$email_to" '/email_to=""/{$0="email_to=\"" net "\""}1' "${astr}" > /tmp/tmp.astr.sh && mv /tmp/tmp.astr.sh "${astr}"
awk -v net="$email_to" '/email_to=""/{$0="email_to=\"" net "\""}1' "${nap}" > /tmp/tmp.nap.sh && mv /tmp/tmp.nap.sh "${nap}"
echo "完成"
