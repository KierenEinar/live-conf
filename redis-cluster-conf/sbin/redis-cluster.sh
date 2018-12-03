#!/bin/bash

SERVER_IP=(redis-cluster-1 redis-cluster-2 redis-cluster-3)
PORT=22
USER="redis"
REDIS_PATH=/opt/redis

function stopAll(){
	for ip in ${SERVER_IP[@]}
        do
                ssh -f -n -p$PORT $USER@$ip "cd ${REDIS_PATH}/sbin && ./stop.sh"
        done
}
function startAll(){
	for ip in ${SERVER_IP[@]}
        do
                ssh -f -n -p$PORT $USER@$ip "cd ${REDIS_PATH}/sbin && ./start.sh"
        done
	sleep 15
	 cd ../bin
        ./redis-cli --cluster create 192.168.200.142:6379 192.168.200.141:6379 192.168.200.136:6379 192.168.200.142:6380 192.168.200.141:6380 192.168.200.136:6380 --cluster-replicas 1
}
function restartAll() {
	stopAll && startAll           
}


while getopts "s:" opt; do
	case $opt in
		s)
			[ "start" == $OPTARG ] && startAll  
			[ "stop" == $OPTARG ] && stopAll  
			[ "restart" == $OPTARG ] && restartAll
		 	sleep 5 && echo $OPTARG success &&  exit 0
		;;
		?)
			echo "invalid options" && exit 0
		;;
	esac	
done	

