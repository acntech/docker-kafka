# Kafka
Docker image with Apache Kafka, based on the acntechie/jre image

Kafka needs Apache ZooKeeper in order to coordinate nodes and runtime operations.

## Configuration
The Kafka instance can be configures using the following environment variables:
* ```KAFKA_BROKER_ID```: A unique ID for the instance.
* ```KAFKA_PORT```: The port the Kafka broker listener will listen on.
* ```KAFKA_HOST```: The hostname the Kafka broker listener will bind to.
* ```KAFKA_LISTENERS```: The hostname and port the Kafka broker will listen on.
* ```KAFKA_LISTENER_PROTOCOL```: The network protocol used for the listeners.
* ```KAFKA_ADVERTISED_LISTENERS```: The hostname and port the Kafka broker will advertise to producers and consumers.
* ```KAFKA_ADVERTISED_LISTENER_PROTOCOL```: The network protocol used for the advertised listeners.
* ```ZOOKEEPER_HOSTS```: A comma separated string of ZooKeeper hosts that Kafka will use for cluster orchestration.

#### Default values
* ```KAFKA_BROKER_ID```: ```1```
* ```KAFKA_PORT```: ```9092```
* ```KAFKA_HOST```: ```$(hostname)```
* ```KAFKA_LISTENERS```: ```${KAFKA_HOST}:${KAFKA_PORT}```
* ```KAFKA_LISTENERS_PROTOCOL```: ```PLAINTEXT```
* ```KAFKA_ADVERTISED_LISTENERS```: ```:${KAFKA_PORT}```
* ```KAFKA_ADVERTISED_LISTENERS_PROTOCOL```: ```PLAINTEXT```
* ```ZOOKEEPER_HOSTS```: ```$(hostname):2181```

## Running single instrance
To run a stand-alone Kafka node you need minimal configuration.

#### Docker Run
First create a network for use with all the nodes:
```
docker network create zookeeper
```

Start an instance of ZooKeeper
```
docker run -d -name lonely_zookeeper --net zookeeper acntechie/zookeeper
```

Now start a Kafka instance:
```
docker run -d -name lonely_kafka -p 9092:9092 --net zookeeper --env ZOOKEEPER_HOSTS=lonely_zookeeper:2181 acntechie/kafka
```

#### Docker Compose
Define a ```docker-compose.yml``` file along the lines of:
```
version: "2"

services:
  lonely_kafka:
    image: acntechie/kafka
    container_name: lonely_kafka
    ports:
      - "9092:9092"
    environment:
      - ZOOKEEPER_HOSTS=lonely_zookeeper:2181
    depends_on:
      - lonely_zookeeper
    networks:
    - zookeeper

  lonely_zookeeper:
    image: acntechie/zookeeper
    container_name: lonely_zookeeper
    networks:
    - zookeeper

networks:
  zookeeper:
```

Then run ```docker-compose up -d``` to create and start a container in daemon mode.

See example file ```docker-compose.standalone.yml```.

## Running cluster
To run a cluser of multiple Kafka nodes you need a bit more configuration.

#### Docker Run
This requires quite a lot of commands, which is too complex for this README. Please see the section for stand-alone operation above together with the Docker Compose section below.

#### Docker Compose
Define a ```docker-compose.yml``` file along the lines of:
```
version: "2"

services:
  friendly_kafka_1:
    image: acntechie/kafka
    container_name: friendly_kafka_1
    ports:
      - "9091:9091"
    environment:
      - KAFKA_BROKER_ID=1
      - KAFKA_PORT=9091
      - ZOOKEEPER_HOSTS=friendly_zookeeper_1:2181,friendly_zookeeper_2:2181,friendly_zookeeper_3:2181
    depends_on:
      - friendly_zookeeper_1
      - friendly_zookeeper_2
      - friendly_zookeeper_3
    networks:
    - zookeeper

  friendly_kafka_2:
    image: acntechie/kafka
    container_name: friendly_kafka_2
    ports:
      - "9092:9092"
    environment:
      - KAFKA_BROKER_ID=2
      - KAFKA_PORT=9092
      - ZOOKEEPER_HOSTS=friendly_zookeeper_1:2181,friendly_zookeeper_2:2181,friendly_zookeeper_3:2181
    depends_on:
      - friendly_zookeeper_1
      - friendly_zookeeper_2
      - friendly_zookeeper_3
    networks:
    - zookeeper

  friendly_kafka_3:
    image: acntechie/kafka
    container_name: friendly_kafka_3
    ports:
      - "9093:9093"
    environment:
      - KAFKA_BROKER_ID=3
      - KAFKA_PORT=9093
      - ZOOKEEPER_HOSTS=friendly_zookeeper_1:2181,friendly_zookeeper_2:2181,friendly_zookeeper_3:2181
    depends_on:
      - friendly_zookeeper_1
      - friendly_zookeeper_2
      - friendly_zookeeper_3
    networks:
    - zookeeper

  friendly_zookeeper_1:
    image: acntechie/zookeeper
    container_name: friendly_zookeeper_1
    environment:
      - ZOOKEEPER_ID=1
      - ZOOKEEPER_HOSTS=friendly_zookeeper_1:2888:3888,friendly_zookeeper_2:2888:3888,friendly_zookeeper_3:2888:3888
    networks:
    - zookeeper

  friendly_zookeeper_2:
    image: acntechie/zookeeper
    container_name: friendly_zookeeper_2
    environment:
      - ZOOKEEPER_ID=2
      - ZOOKEEPER_HOSTS=friendly_zookeeper_1:2888:3888,friendly_zookeeper_2:2888:3888,friendly_zookeeper_3:2888:3888
    networks:
    - zookeeper

  friendly_zookeeper_3:
    image: acntechie/zookeeper
    container_name: friendly_zookeeper_3
    environment:
      - ZOOKEEPER_ID=3
      - ZOOKEEPER_HOSTS=friendly_zookeeper_1:2888:3888,friendly_zookeeper_2:2888:3888,friendly_zookeeper_3:2888:3888
    networks:
    - zookeeper

networks:
  zookeeper:
```

Then run ```docker-compose up -d``` to create and start all containers in daemon mode.

See example file ```docker-compose.cluster.yml```.
