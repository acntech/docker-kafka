#!/bin/bash

KAFKA_CONFIGURED_FLAG="${HOME}/.kafka_configured"
KAFKA_SERVER_PROPERTIES="${KAFKA_HOME}/config/server.properties"
KAFKA_SERVER_CMD="${KAFKA_HOME}/bin/kafka-server-start.sh ${KAFKA_SERVER_PROPERTIES}"
ZOOKEEPER_PROPERTIES="${KAFKA_HOME}/config/zookeeper.properties"

if [ ! -f ${KAFKA_CONFIGURED_FLAG} ]; then

   echo "Configuring Kafka..."

   KAFKA_BROKER_ID=${KAFKA_BROKER_ID:-0}
   ZOOKEEPER_HOSTS=${ZOOKEEPER_HOSTS:-localhost:2181}

   echo "Sanitizing old Kafka configuration..."
   sed -i 's/broker\.id=.*//g' ${KAFKA_SERVER_PROPERTIES}
   sed -i 's/zookeeper\.connect=.*//g' ${KAFKA_SERVER_PROPERTIES}

   echo "Setting Kafka broker ID: ${KAFKA_BROKER_ID}"
   echo "broker.id=${KAFKA_BROKER_ID}" >> ${KAFKA_SERVER_PROPERTIES}

   echo "Setting ZooKeeper hosts: ${ZOOKEEPER_HOSTS}"
   echo "zookeeper.connect=${ZOOKEEPER_HOSTS}" >> ${KAFKA_SERVER_PROPERTIES}

   date > ${KAFKA_CONFIGURED_FLAG}

else
   echo "Kafka is already configured..."
fi

echo "Starting Kafka..."
echo "Command: ${KAFKA_SERVER_CMD}"

${KAFKA_SERVER_CMD}
