#!/bin/bash

KAFKA_CONFIGURED_FLAG="${HOME}/.kafka_configured"
KAFKA_BROKER_ID=${KAFKA_BROKER_ID:-1}

KAFKA_PORT=${KAFKA_PORT:-9092}
KAFKA_PROTOCOL=${KAFKA_PROTOCOL:-PLAINTEXT}

KAFKA_LISTENERS=${KAFKA_LISTENERS:-${KAFKA_PROTOCOL}://0.0.0.0:${KAFKA_PORT}}
KAFKA_ADVERTISED_LISTENERS=${KAFKA_ADVERTISED_LISTENERS:-${KAFKA_PROTOCOL}://localhost:${KAFKA_PORT}}

KAFKA_SERVER_PROPERTIES="${KAFKA_HOME}/config/server.properties"
KAFKA_SERVER_CMD="${KAFKA_HOME}/bin/kafka-server-start.sh ${KAFKA_SERVER_PROPERTIES}"

if [ -f ${KAFKA_CONFIGURED_FLAG} ]; then
   echo "Kafka has already been configured, continuing..."
else
   echo "Configuring Kafka..."

   echo "Setting Kafka broker ID: ${KAFKA_BROKER_ID}"
   sed -i -r 's@#?broker.id=.*@broker.id='"${KAFKA_BROKER_ID}"'@g' ${KAFKA_SERVER_PROPERTIES}

   echo "Setting Kafka listeners: ${KAFKA_LISTENERS}"
   sed -i -r 's@#?listeners=.*@listeners='"${KAFKA_LISTENERS}"'@g' ${KAFKA_SERVER_PROPERTIES}

   echo "Setting Kafka advertised listeners: ${KAFKA_ADVERTISED_LISTENERS}"
   sed -i -r 's@#?advertised.listeners=.*@advertised.listeners='"${KAFKA_ADVERTISED_LISTENERS}"'@g' ${KAFKA_SERVER_PROPERTIES}

   echo "Setting Kafka data dir: ${KAFKA_DATA_DIR}"
   sed -i -r 's@#?log.dirs=.*@log.dirs='"${KAFKA_DATA_DIR}"'@g' ${KAFKA_SERVER_PROPERTIES}

   if [ -z "${ZOOKEEPER_HOSTS}" ]; then
      echo "ERROR: Environment variable for ZooKeeper hosts ZOOKEEPER_HOSTS is not defined"
      exit 1
   fi

   echo "Setting ZooKeeper hosts: ${ZOOKEEPER_HOSTS}"
   sed -i -r 's@#?zookeeper.connect=.*@zookeeper.connect='"${ZOOKEEPER_HOSTS}"'@g' ${KAFKA_SERVER_PROPERTIES}

   date > ${KAFKA_CONFIGURED_FLAG}
fi

echo "Starting Kafka..."
echo "Command: ${KAFKA_SERVER_CMD}"

${KAFKA_SERVER_CMD}
