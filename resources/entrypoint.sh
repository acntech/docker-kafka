#!/bin/bash

KAFKA_CONFIGURED_FLAG="${HOME}/.kafka_configured"
KAFKA_SERVER_PROPERTIES="${KAFKA_HOME}/config/server.properties"
KAFKA_SERVER_CMD="${KAFKA_HOME}/bin/kafka-server-start.sh ${KAFKA_SERVER_PROPERTIES}"
ZOOKEEPER_PROPERTIES="${KAFKA_HOME}/config/zookeeper.properties"

if [ ! -f ${KAFKA_CONFIGURED_FLAG} ]; then

   echo "Configuring Kafka..."

   KAFKA_BROKER_ID=${KAFKA_BROKER_ID:-0}
   KAFKA_ADVERTISED_LISTENERS=${KAFKA_ADVERTISED_LISTENERS:-localhost:9092}
   ZOOKEEPER_HOSTS=${ZOOKEEPER_HOSTS:-localhost:2181}

   echo "Setting Kafka broker ID: ${KAFKA_BROKER_ID}"
   sed -i 's/^#*broker\.id=.*/broker.id='"${KAFKA_BROKER_ID}"'/g' ${KAFKA_SERVER_PROPERTIES}

   echo "Setting Kafka advertised listeners: ${KAFKA_ADVERTISED_LISTENERS}"
   sed -i 's/^#*advertised\.listeners=.*/advertised.listeners=PLAINTEXT:\/\/'"${KAFKA_ADVERTISED_LISTENERS}"'/g' ${KAFKA_SERVER_PROPERTIES}

   echo "Setting ZooKeeper hosts: ${ZOOKEEPER_HOSTS}"
   sed -i 's/^#*zookeeper\.connect=.*/zookeeper.connect='"${ZOOKEEPER_HOSTS}"'/g' ${KAFKA_SERVER_PROPERTIES}

   date > ${KAFKA_CONFIGURED_FLAG}

else
   echo "Kafka is already configured..."
fi

echo "Starting Kafka..."
echo "Command: ${KAFKA_SERVER_CMD}"

${KAFKA_SERVER_CMD}
