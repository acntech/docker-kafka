#!/bin/bash

KAFKA_CONFIGURED_FLAG="${HOME}/.kafka_configured"
KAFKA_BROKER_ID=${KAFKA_BROKER_ID:-1}

KAFKA_PORT=${KAFKA_PORT:-9092}
KAFKA_HOST=${KAFKA_HOST:-$(hostname)}
KAFKA_PROTOCOL=${KAFKA_PROTOCOL:-PLAINTEXT}

KAFKA_LISTENERS_PROTOCOL=${KAFKA_LISTENERS_PROTOCOL:-${KAFKA_PROTOCOL}}
KAFKA_LISTENERS=${KAFKA_LISTENERS:-${KAFKA_HOST}:${KAFKA_PORT}}

KAFKA_ADVERTISED_LISTENERS_PROTOCOL=${KAFKA_ADVERTISED_LISTENERS_PROTOCOL:-${KAFKA_PROTOCOL}}
KAFKA_ADVERTISED_LISTENERS=${KAFKA_ADVERTISED_LISTENERS:-:${KAFKA_PORT}}

KAFKA_SERVER_PROPERTIES="${KAFKA_HOME}/config/server.properties"
KAFKA_SERVER_CMD="${KAFKA_HOME}/bin/kafka-server-start.sh ${KAFKA_SERVER_PROPERTIES}"

ZOOKEEPER_HOSTS=${ZOOKEEPER_HOSTS:-$(hostname):2181}

if [ ! -f ${KAFKA_CONFIGURED_FLAG} ]; then

   echo "Configuring Kafka..."

   echo "Setting Kafka broker ID: ${KAFKA_BROKER_ID}"
   sed -i 's@broker.id=.*@broker.id='"${KAFKA_BROKER_ID}"'@g' ${KAFKA_SERVER_PROPERTIES}

   echo "Setting Kafka port: ${KAFKA_PORT}"
   sed -i 's@port=.*@port='"${KAFKA_PORT}"'@g' ${KAFKA_SERVER_PROPERTIES}

   echo "Setting Kafka listeners: ${KAFKA_LISTENERS}"
   sed -i 's@listeners=.*@listeners='"${KAFKA_LISTENERS}"'@g' ${KAFKA_SERVER_PROPERTIES}

   echo "Setting Kafka advertised listeners: ${KAFKA_ADVERTISED_LISTENERS}"
   sed -i 's@advertised.listeners=.*@advertised.listeners='"${KAFKA_ADVERTISED_LISTENERS}"'@g' ${KAFKA_SERVER_PROPERTIES}

   echo "Setting Kafka data dir: ${KAFKA_DATA_DIR}"
   sed -i 's@log.dirs=.*@log.dirs='"${KAFKA_DATA_DIR}"'@g' ${KAFKA_SERVER_PROPERTIES}

   echo "Setting ZooKeeper hosts: ${ZOOKEEPER_HOSTS}"
   sed -i 's@zookeeper.connect=.*@zookeeper.connect='"${ZOOKEEPER_HOSTS}"'@g' ${KAFKA_SERVER_PROPERTIES}

   date > ${KAFKA_CONFIGURED_FLAG}

else
   echo "Kafka has already been configured, continuing..."
fi

echo "Starting Kafka..."
echo "Command: ${KAFKA_SERVER_CMD}"

${KAFKA_SERVER_CMD}
