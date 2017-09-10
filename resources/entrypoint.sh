#!/bin/bash

KAFKA_CONFIGURED_FLAG="${HOME}/.kafka_configured"
KAFKA_BROKER_ID=${KAFKA_BROKER_ID:-1}
KAFKA_ADVERTISED_LISTENERS=${KAFKA_ADVERTISED_LISTENERS:-$(hostname):9092}
KAFKA_ADVERTISED_LISTENERS_PROTOCOL=${KAFKA_ADVERTISED_LISTENERS_PROTOCOL:-PLAINTEXT}
KAFKA_SERVER_PROPERTIES="${KAFKA_HOME}/config/server.properties"
KAFKA_SERVER_CMD="${KAFKA_HOME}/bin/kafka-server-start.sh ${KAFKA_SERVER_PROPERTIES}"
ZOOKEEPER_PROPERTIES="${KAFKA_HOME}/config/zookeeper.properties"
ZOOKEEPER_HOSTS=${ZOOKEEPER_HOSTS:-$(hostname):2181}

if [ ! -f ${KAFKA_CONFIGURED_FLAG} ]; then

   echo "Configuring Kafka..."

   echo "Sanitizing old Kafka configuration..."
   sed -i 's/broker\.id=.*//g' ${KAFKA_SERVER_PROPERTIES}
   sed -i 's/advertised\.listeners=.*//g' ${KAFKA_SERVER_PROPERTIES}
   sed -i 's/log\.dirs=.*//g' ${KAFKA_SERVER_PROPERTIES}
   sed -i 's/zookeeper\.connect=.*//g' ${KAFKA_SERVER_PROPERTIES}

   echo "Setting Kafka broker ID: ${KAFKA_BROKER_ID}"
   echo -e "\n\n" >> ${KAFKA_SERVER_PROPERTIES}
   echo "broker.id=${KAFKA_BROKER_ID}" >> ${KAFKA_SERVER_PROPERTIES}

   echo "Setting Kafka advertised listeners: ${KAFKA_ADVERTISED_LISTENERS}"
   echo -e "\n\n" >> ${KAFKA_SERVER_PROPERTIES}
   echo "advertised.listeners=${KAFKA_ADVERTISED_LISTENERS_PROTOCOL}://${KAFKA_ADVERTISED_LISTENERS}" >> ${KAFKA_SERVER_PROPERTIES}

   echo "Setting Kafka data dir: ${KAFKA_DATA_DIR}"
   echo -e "\n\n" >> ${KAFKA_SERVER_PROPERTIES}
   echo "log.dirs=${KAFKA_DATA_DIR}" >> ${KAFKA_SERVER_PROPERTIES}

   echo "Setting ZooKeeper hosts: ${ZOOKEEPER_HOSTS}"
   echo -e "\n\n" >> ${KAFKA_SERVER_PROPERTIES}
   echo "zookeeper.connect=${ZOOKEEPER_HOSTS}" >> ${KAFKA_SERVER_PROPERTIES}

   date > ${KAFKA_CONFIGURED_FLAG}

else
   echo "Kafka has already been configured, continuing..."
fi

echo "Starting Kafka..."
echo "Command: ${KAFKA_SERVER_CMD}"

${KAFKA_SERVER_CMD}
