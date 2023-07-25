#!/bin/bash

# 阿里云盘新增资源后,刷新rclone挂载本地网盘,重启nastool容器刷新文件缓存

# 关闭nastool容器
sh /data1/nastool/bin/nastool_manage.sh stop 

# 重载rclone
sh /data1/rclone/rclone_tool.sh reload

# 启动nastool容器
sh /data1/nastool/bin/nastool_manage.sh start
