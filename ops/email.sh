#!/bin/bash
#!/bin/sh
set -e
CONTAINER="postfix"
#发件人填postfix的qq邮箱
FROM_ADDR=""
FROM_NAME="告警系统"                    # 邮件头显示名，可改

if [ $# -lt 2 ]; then
    echo "用法: $0 <收件人> <主题> [正文]"
    exit 1
fi

TO_ADDR="$1"
SUBJECT="$2"
BODY="${3:-无正文}"

SUBJECT_ESC=$(printf '%s' "$SUBJECT" | sed 's/%/%%/g; s/\\/\\\\/g')
BODY_ESC=$(printf '%s' "$BODY" | sed 's/%/%%/g; s/\\/\\\\/g')

docker exec -i "$CONTAINER" sendmail -f "$FROM_ADDR" -v "$TO_ADDR" <<EOF
From: $FROM_NAME <$FROM_ADDR>
To: <$TO_ADDR>
Subject: $SUBJECT
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit

$BODY
EOF

echo "已提交到 Postfix 队列，收件人: $TO_ADDR"
