#!/bin/bash
cp /opt/ops/service/*.service /etc/systemd/system/
systemctl daemon-reload
for file in /opt/ops/service/*.service
do
    service_name=$(basename "${file}")
    systemctl enable "${service_name}"
    systemctl start "${service_name}"
done

