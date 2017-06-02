FROM acntechie/jre
MAINTAINER Thomas Johansen "thomas.johansen@accenture.com"


ARG KAFKA_VERSION=0.10.2.1
ARG SCALA_VERSION=2.12
ARG KAFKA_DIR=kafka_${SCALA_VERSION}-${KAFKA_VERSION}


ENV KAFKA_BASE /opt/kafka
ENV KAFKA_HOME ${KAFKA_BASE}/default
ENV KAFKA_LOG_DIR /var/log/kafka
ENV PATH ${PATH}:${KAFKA_HOME}/bin


RUN apt-get update && \
    apt-get -y upgrade

RUN mkdir -p ${KAFKA_BASE} && \
    mkdir ${KAFKA_LOG_DIR}

RUN wget --no-cookies \
         --no-check-certificate \
         "https://dist.apache.org/repos/dist/release/kafka/${KAFKA_VERSION}/${KAFKA_DIR}.tgz" \
         -O /tmp/kafka.tar.gz

RUN wget --no-cookies \
         --no-check-certificate \
         "https://dist.apache.org/repos/dist/release/kafka/${KAFKA_VERSION}/${KAFKA_DIR}.tgz.asc" \
         -O /tmp/kafka.tar.gz.asc

RUN wget --no-cookies \
         --no-check-certificate \
         "https://dist.apache.org/repos/dist/release/kafka/KEYS" \
         -O /tmp/kafka.KEYS

RUN gpg --import /tmp/kafka.KEYS && \
    gpg --batch --verify /tmp/kafka.tar.gz.asc /tmp/kafka.tar.gz

RUN tar -xzvf /tmp/kafka.tar.gz -C ${KAFKA_BASE}/ && \
    cd ${KAFKA_BASE} && \
    ln -s ${KAFKA_DIR}/ default && \
    rm -f /tmp/kafka.*


COPY ./resources/entrypoint.sh /entrypoint.sh


RUN chmod +x /entrypoint.sh


EXPOSE 9000 9092


WORKDIR ${KAFKA_HOME}


VOLUME "${KAFKA_HOME}/config"
VOLUME "${KAFKA_LOG_DIR}"


ENTRYPOINT ["/entrypoint.sh"]