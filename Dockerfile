FROM eclipse-temurin:17-jre
MAINTAINER Thomas Johansen "thomas.johansen@accenture.com"


ARG KAFKA_VERSION=3.2.0
ARG SCALA_VERSION=2.13
ARG KAFKA_MIRROR=https://dist.apache.org/repos/dist/release/kafka
ARG KAFKA_KEY_MIRROR=https://dist.apache.org/repos/dist/release/kafka
ARG KAFKA_DIR=kafka_${SCALA_VERSION}-${KAFKA_VERSION}


ENV KAFKA_BASE /opt/kafka
ENV KAFKA_HOME ${KAFKA_BASE}/default
ENV KAFKA_DATA_ROOT /var/lib/kafka
ENV KAFKA_DATA_DIR ${KAFKA_DATA_ROOT}/data
ENV KAFKA_LOG_DIR ${KAFKA_DATA_ROOT}/logs
ENV LOG_DIR ${KAFKA_LOG_DIR}
ENV PATH ${PATH}:${KAFKA_HOME}/bin


WORKDIR /tmp


RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install gpg && \
    rm -rf /var/lib/apt/lists/*

RUN curl --silent --show-error --output kafka.tar.gz \
         "${KAFKA_MIRROR}/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz" && \
    curl --silent --show-error --output kafka.tar.gz.asc \
         "${KAFKA_KEY_MIRROR}/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz.asc" && \
    curl --silent --show-error --output kafka.KEYS \
         "${KAFKA_KEY_MIRROR}/KEYS"

RUN gpg --quiet --import --no-tty kafka.KEYS && \
    gpg --quiet --batch --verify --no-tty kafka.tar.gz.asc kafka.tar.gz

RUN mkdir -p ${KAFKA_BASE} && \
    mkdir -p ${KAFKA_DATA_DIR} && \
    mkdir -p ${KAFKA_LOG_DIR} && \
    cd /var/log && \
    ln -s ${KAFKA_LOG_DIR}/ kafka && \
    tar -xzvf /tmp/kafka.tar.gz -C ${KAFKA_BASE}/ && \
    cd ${KAFKA_BASE} && \
    ln -s ${KAFKA_DIR}/ default && \
    rm -f /tmp/kafka.*


COPY ./resources/entrypoint.sh /entrypoint.sh


RUN chown -R root:root ${KAFKA_BASE} && \
    chmod +x /entrypoint.sh


EXPOSE 9000 9092


WORKDIR ${KAFKA_HOME}


VOLUME "${KAFKA_DATA_ROOT}"


ENTRYPOINT ["/entrypoint.sh"]