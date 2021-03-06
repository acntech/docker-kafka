#!/bin/bash

KAFKA_CONFIGURED_FLAG="${HOME}/.kafka_configured"
KAFKA_BROKER_ID=${KAFKA_BROKER_ID:-1}

KAFKA_PORT=${KAFKA_PORT:-9092}
KAFKA_PROTOCOL=${KAFKA_PROTOCOL:-PLAINTEXT}

KAFKA_LISTENERS=${KAFKA_LISTENERS:-${KAFKA_PROTOCOL}://0.0.0.0:${KAFKA_PORT}}
KAFKA_ADVERTISED_LISTENERS=${KAFKA_ADVERTISED_LISTENERS:-${KAFKA_PROTOCOL}://localhost:${KAFKA_PORT}}

KAFKA_AUTO_CREATE_TOPICS_ENABLE=${KAFKA_AUTO_CREATE_TOPICS_ENABLE:-true}

KAFKA_SERVER_PROPERTIES="${KAFKA_HOME}/config/server.properties"
KAFKA_SERVER_CMD="${KAFKA_HOME}/bin/kafka-server-start.sh ${KAFKA_SERVER_PROPERTIES}"

if [ -f ${KAFKA_CONFIGURED_FLAG} ]; then
   echo "Kafka has already been configured, continuing..."
else
   echo "Configuring Kafka..."

   if [ -z "${KAFKA_BROKER_ID}" ]; then
      echo "ERROR: Environment variable KAFKA_BROKER_ID is not defined"
      exit 1
   else
      echo "Setting Kafka config broker.id=${KAFKA_BROKER_ID}"
      sed -i -r 's@#?broker.id=.*@broker.id='"${KAFKA_BROKER_ID}"'@g' ${KAFKA_SERVER_PROPERTIES}
   fi

   if [ -z "${KAFKA_LISTENERS}" ]; then
      echo "ERROR: Environment variable KAFKA_LISTENERS is not defined"
      exit 1
   else
      echo "Setting Kafka config listeners=${KAFKA_LISTENERS}"
      sed -i -r 's@#?listeners=.*@listeners='"${KAFKA_LISTENERS}"'@g' ${KAFKA_SERVER_PROPERTIES}
   fi

   if [ -z "${KAFKA_ADVERTISED_LISTENERS}" ]; then
      echo "ERROR: Environment variable KAFKA_ADVERTISED_LISTENERS is not defined"
      exit 1
   else
      echo "Setting Kafka config advertised.listeners=${KAFKA_ADVERTISED_LISTENERS}"
      sed -i -r 's@#?advertised.listeners=.*@advertised.listeners='"${KAFKA_ADVERTISED_LISTENERS}"'@g' ${KAFKA_SERVER_PROPERTIES}
   fi

   if [ -z "${KAFKA_AUTO_CREATE_TOPICS_ENABLE}" ]; then
      echo "ERROR: Environment variable KAFKA_AUTO_CREATE_TOPICS_ENABLE is not defined"
      exit 1
   else
      echo "Setting Kafka config auto.create.topics.enable=${KAFKA_AUTO_CREATE_TOPICS_ENABLE}"
      sed -i -r 's@#?auto.create.topics.enable=.*@auto.create.topics.enable='"${KAFKA_AUTO_CREATE_TOPICS_ENABLE}"'@g' ${KAFKA_SERVER_PROPERTIES}
   fi

   if [ -z "${KAFKA_DATA_DIR}" ]; then
      echo "ERROR: Environment variable KAFKA_DATA_DIR is not defined"
      exit 1
   else
     echo "Setting Kafka config log.dirs=${KAFKA_DATA_DIR}"
     sed -i -r 's@#?log.dirs=.*@log.dirs='"${KAFKA_DATA_DIR}"'@g' ${KAFKA_SERVER_PROPERTIES}
   fi

   if [ -z "${ZOOKEEPER_HOSTS}" ]; then
      echo "ERROR: Environment variable ZOOKEEPER_HOSTS is not defined"
      exit 1
   else
      echo "Setting Kafka config zookeeper.connect=${ZOOKEEPER_HOSTS}"
      sed -i -r 's@#?zookeeper.connect=.*@zookeeper.connect='"${ZOOKEEPER_HOSTS}"'@g' ${KAFKA_SERVER_PROPERTIES}
   fi

   date > ${KAFKA_CONFIGURED_FLAG}
fi

echo "Starting Kafka..."
echo "Command: ${KAFKA_SERVER_CMD}"

${KAFKA_SERVER_CMD}
