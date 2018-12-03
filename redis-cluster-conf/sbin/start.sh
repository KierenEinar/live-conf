#!/bin/bash

REDIS_PATH=/opt/redis
echo "ready start redis master and slave process"
rm -rf ${REDIS_PATH}/redis_6379/data && mkdir -p ${REDIS_PATH}/redis_6379/data
rm -rf ${REDIS_PATH}/redis_6380/data && mkdir -p ${REDIS_PATH}/redis_6380/data
${REDIS_PATH}/bin/redis-server ${REDIS_PATH}/redis_6379/conf/redis.conf && ${REDIS_PATH}/bin/redis-server ${REDIS_PATH}/redis_6380/conf/redis.conf
echo "finished start redis master and slave process"
