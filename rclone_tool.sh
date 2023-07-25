#!/bin/bash

# aliyunpan挂载工具

# 使用帮助
usage(){
    echo -e "\033[33mUsage: sh $0 [mount|umount|reload|check]\033[0m"
}

# 挂载云盘
mount(){
    /usr/bin/rclone mount alist: /data1/aliyunpan --use-mmap --umask 000 --allow-other --allow-non-empty --dir-cache-time 24h --cache-dir=/home/cache --vfs-cache-mode full --buffer-size 512M --vfs-read-chunk-size 16M --vfs-read-chunk-size-limit 64M --vfs-cache-max-size 10G --daemon
}

# 卸载云盘
umount(){
    /usr/bin/fusermount  -qzu /data1/aliyunpan
}

# 检查云盘挂载状态
check(){
    mount_status=$(df -h |grep alist | awk '{print $1}')
    # echo -e "mount_status:$mount_status"
    if [ -z $mount_status ];then
        echo -e "\033[33m>>> aliyunpan has been uninstalled, please check the system disk mount status \033[0m"
    else
        echo -e "\033[32m>>> aliyunpan has been mounted \033[0m"
    fi
}


case $1 in 
    mount) 
        mount && check ;;
    umount) 
        umount && check ;;
    reload) 
        umount && check && mount && check;;
    check)
        check ;;
    *)  
        usage ;;
esac
