#!/bin/bash

# nastool管理工具

usage(){
    echo -e "\033[33mUsage: sh $0 [stop|start|check]\033[0m"
}

stop(){
    echo -e "\033[33m>>> nastool is stopping, wait a minute\033[0m"
    docker ps -a |grep nas-tools-v2 | awk  '{print $NF}' | xargs  docker stop >/dev/null
}

start(){
    docker ps -a |grep nas-tools-v2 | awk  '{print $NF}' | xargs  docker start >/dev/null
}

check(){
    netstat -nltp |grep 9092 >/dev/null && echo -e "\033[32m>>> nastool is running\033[0m" || echo -e "\033[33m>>> nastool has stopped\033[0m"
}

case $1 in
    stop)
        stop && check ;;
    start)
        start && check;;
    check)
        check;;
    *)
        usage;
esac
