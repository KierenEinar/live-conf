#!/bin/bash

USER=`whoami`
DEPLOY_PATH=/opt/redis
PORTS=(6379 6380)
SERVER1_IP=192.168.200.142
SERVER2_IP=192.168.200.141
SERVER3_IP=192.168.200.136
SERVER_USER="redis"
SERVER_PORT=22
function init() {
	for i in ${PORTS[@]}
	do
        	[ -d ${DEPLOY_PATH}/redis_${i} ] || mkdir ${DEPLOY_PATH}/redis_${i}
        	[ -d ${DEPLOY_PATH}/redis_${i}/data ] || mkdir ${DEPLOY_PATH}/redis_${i}/data
        	[ -d ${DEPLOY_PATH}/redis_${i}/conf ] || mkdir ${DEPLOY_PATH}/redis_${i}/conf
        	[ -d ${DEPLOY_PATH}/redis_${i}/conf/redis.conf ] || cp $DEPLOY_PATH/redis.template.conf ${DEPLOY_PATH}/redis_${i}/conf/redis.conf
	done

	for i in ${PORTS[@]}
	do
        	CONF_PATH=${DEPLOY_PATH}/redis_${i}/conf/redis.conf
        	echo "${CONF_PATH}"
        	DATA_PATH=${DEPLOY_PATH}/redis_${i}/data
		rm -rf ${DATA_PATH} && mkdir -p ${DATA_PATH}
        	sed -i "s/bind 127.0.0.1/bind 0.0.0.0/g" ${CONF_PATH}
        	sed -i "s/port 6379/port ${i}/g" ${CONF_PATH}
        	sed -i "s/daemonize no/daemonize yes/g" ${CONF_PATH}
        	sed -i "s?pidfile /var/run/redis_6379.pid?pidfile /var/run/redis_${i}.pid?" ${CONF_PATH}
        	sed -i "s?dir ./?dir ${DATA_PATH}?" ${CONF_PATH}
        	#[ $i -eq 6380 ] && sed -i "s/# masterauth <master-password>/masterauth aqovnuJGBvX4Bzi0/g" ${CONF_PATH}  
		#[ $i -eq 6379 ] && sed -i "s/# requirepass foobared/requirepass aqovnuJGBvX4Bzi0/g" ${CONF_PATH}
        	sed -i "s/appendonly no/appendonly yes/g" ${CONF_PATH}
        	sed -i "s/# cluster-enabled yes/cluster-enabled yes/g" ${CONF_PATH}


	done

} 

function upload(){
	echo "ready to upload..."
	echo "${DEPLOY_PATH}"
	IP=`/sbin/ifconfig -a|grep inet|grep -v 127.0.0.1|grep -v inet6 | awk '{print $2}' | tr -d "addr:"`
	case $IP in
		
		$SERVER1_IP)
		echo case 1
		 scp -r ${DEPLOY_PATH} $SERVER_USER@$SERVER3_IP:/opt
        	 ssh -f -n -p$SERVER_PORT $SERVER_USER@$SERVER3_IP "chmod u+x ${DEPLOY_PATH}/sbin/*.sh"

        	 #ssh -f -n -p$SERVER_PORT $SERVER_USER@$SERVER2_IP "rm -rf ${DEPLOY_PATH}"
        	scp -r ${DEPLOY_PATH} $SERVER_USER@$SERVER2_IP:/opt
        	ssh -f -n -p$SERVER_PORT $SERVER_USER@$SERVER2_IP "chmod u+x ${DEPLOY_PATH}/sbin/*.sh"
		;;
		$SERVER2_IP)
		echo case 2
		 scp -r ${DEPLOY_PATH} $SERVER_USER@$SERVER1_IP:/opt
        	 ssh -f -n -p$SERVER_PORT $SERVER_USER@$SERVER1_IP "chmod u+x ${DEPLOY_PATH}/sbin/*.sh"

        	#ssh -f -n -p$SERVER_PORT $SERVER_USER@$SERVER2_IP "rm -rf ${DEPLOY_PATH}"
        	scp -r ${DEPLOY_PATH} $SERVER_USER@$SERVER3_IP:/opt
        	ssh -f -n -p$SERVER_PORT $SERVER_USER@$SERVER3_IP "chmod u+x ${DEPLOY_PATH}/sbin/*.sh"
		;;
		
		$SERVER3_IP)
		echo case 3
		 scp -r ${DEPLOY_PATH} $SERVER_USER@$SERVER1_IP:/opt
        	ssh -f -n -p$SERVER_PORT $SERVER_USER@$SERVER1_IP "chmod u+x ${DEPLOY_PATH}/sbin/*.sh"

        #ssh -f -n -p$SERVER_PORT $SERVER_USER@$SERVER2_IP "rm -rf ${DEPLOY_PATH}"
        scp -r ${DEPLOY_PATH} $SERVER_USER@$SERVER2_IP:/opt
        ssh -f -n -p$SERVER_PORT $SERVER_USER@$SERVER2_IP "chmod u+x ${DEPLOY_PATH}/sbin/*.sh"

		;;
	esac

	echo "finished to upload"
}


init && upload


