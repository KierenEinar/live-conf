#!/bin/bash

USER=`whoami`;
pname="redis-server"
pids=`ps -fu ${USER}| grep -w ${pname} | grep -v grep | awk '{print $2}'`
[ -z "${pids}" ] && echo "pids not found" && exit 0

for pid in ${pids}
do
	kill ${pid}
	echo "stop process: ${pid}"
	sleep 2;
	cn=`ps -p $pid |wc -l`
        if [ $cn -gt 1 ]; then
            kill -9 $pid
        fi
done
rm -rf /opt/redis/redis_6379/data
rm -rf /opt/redis/redis_6380/data 
