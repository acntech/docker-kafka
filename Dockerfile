FROM openjdk:8-jre
MAINTAINER Thomas Johansen "thomas.johansen@accenture.com"


ARG KAFKA_VERSION=2.3.1
ARG SCALA_VERSION=2.12
ARG KAFKA_MIRROR=https://dist.apache.org/repos/dist/release/kafka
ARG KAFKA_KEY_MIRROR=https://dist.apache.org/repos/dist/release/kafka
ARG KAFKA_DIR=kafka_${SCALA_VERSION}-${KAFKA_VERSION}


ENV KAFKA_BASE /opt/kafka
ENV KAFKA_HOME ${KAFKA_BASE}/default
ENV KAFKA_DATA_DIR /var/lib/kafka
ENV KAFKA_LOG_DIR /var/log/kafka
ENV LOG_DIR ${KAFKA_LOG_DIR}
ENV PATH ${PATH}:${KAFKA_HOME}/bin


WORKDIR /tmp


RUN apt-get update && \
    apt-get -y upgrade && \
    rm -rf /var/lib/apt/lists/*

RUN wget --no-cookies \
         --no-check-certificate \
         "${KAFKA_MIRROR}/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz" \
         -O kafka.tar.gz

RUN wget --no-cookies \
         --no-check-certificate \
         "${KAFKA_KEY_MIRROR}/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz.asc" \
         -O kafka.tar.gz.asc

RUN wget --no-cookies \
         --no-check-certificate \
         "${KAFKA_KEY_MIRROR}/KEYS" \
         -O kafka.KEYS

RUN gpg --import --no-tty kafka.KEYS && \
    gpg --batch --verify --no-tty kafka.tar.gz.asc kafka.tar.gz

RUN mkdir -p ${KAFKA_BASE} && \
    mkdir ${KAFKA_DATA_DIR} && \
    mkdir ${KAFKA_LOG_DIR} && \
    tar -xzvf kafka.tar.gz -C ${KAFKA_BASE}/ && \
    cd ${KAFKA_BASE} && \
    ln -s ${KAFKA_DIR}/ default && \
    rm -f kafka.*


COPY resources/entrypoint.sh /entrypoint.sh


RUN chown -R root:root ${KAFKA_BASE}
RUN chmod +x /entrypoint.sh


EXPOSE 9000 9092


WORKDIR ${KAFKA_HOME}


VOLUME "${KAFKA_HOME}/config"
VOLUME "${KAFKA_DATA_DIR}"
VOLUME "${KAFKA_LOG_DIR}"


ENTRYPOINT ["/entrypoint.sh"]