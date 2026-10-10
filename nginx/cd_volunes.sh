#!/bin/bash
echo "输入数字1、2、3、4"
echo "1)编写从conf.d/default.conf节点配置文件"
echo "2)编写nginx.conf主配置文件"
echo "3)热加载nginx容器配置"
echo "4)退出"
while true;do
read change
case $change in
1)	
vim /var/lib/docker/volumes/ngconf/_data/conf.d/default.conf
;;
2)
vim /var/lib/docker/volumes/ngconf/_data/nginx.conf
;;
3)
docker exec nginx nginx -t
if [ $? -ne 0 ];then
	echo "校验配置文件失败，请重新配置"
else
	docker exec nginx nginx -s reload
	echo "热加载完成"
fi
;;
4)
break
;;
esac
done
