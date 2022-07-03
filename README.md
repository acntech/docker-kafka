# Kafka
Docker image with Apache Kafka, based on the openjdk:11-jre image

Kafka needs Apache ZooKeeper in order to coordinate nodes and runtime operations.

## Configuration
The Kafka instance can be configures using the following environment variables:
* ```KAFKA_BROKER_ID```: A unique ID for the instance.
* ```KAFKA_PORT```: The port the Kafka broker listener will listen on.
* ```KAFKA_PROTOCOL```: The protocol used for the listeners.
* ```KAFKA_LISTENERS```: The hostname and port the Kafka broker will listen on.
* ```KAFKA_ADVERTISED_LISTENERS```: The hostname and port the Kafka broker will advertise to producers and consumers.
* ```ZOOKEEPER_HOSTS```: A comma separated string of ZooKeeper hosts that Kafka will use for cluster orchestration.

#### Default values
* ```KAFKA_BROKER_ID```: ```1```
* ```KAFKA_PORT```: ```9092```
* ```KAFKA_PROTOCOL```: ```PLAINTEXT```
* ```KAFKA_LISTENERS```: ```${KAFKA_PROTOCOL}://0.0.0.0:${KAFKA_PORT}```
* ```KAFKA_ADVERTISED_LISTENERS```: ```${KAFKA_PROTOCOL}://localhost:${KAFKA_PORT}```

## Running single instrance
To run a stand-alone Kafka node you need minimal configuration.

#### Docker Run
First create a network for use with all the nodes:
```
docker network create zookeeper
```

Start an instance of ZooKeeper
```
docker run -d -name lonely.zookeeper --net zookeeper acntechie/zookeeper
```

Now start a Kafka instance:
```
docker run -d -name lonely.kafka -p 9092:9092 --net zookeeper --env ZOOKEEPER_HOSTS=lonely.zookeeper:2181 acntechie/kafka
```

#### Docker Compose
Define a ```docker-compose.yml``` file along the lines of:
```
version: "3.5"

services:
  lonely.kafka:
    image: acntechie/kafka
    container_name: lonely.kafka
    ports:
      - "9092:9092"
    environment:
      - ZOOKEEPER_HOSTS=lonely.zookeeper:2181
    depends_on:
      - lonely.zookeeper
    networks:
    - kafka

  lonely.zookeeper:
    image: acntechie/zookeeper
    container_name: lonely.zookeeper
    networks:
    - kafka

networks:
  kafka:
    name: kafka
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
version: "3.5"

services:
  friendly.kafka.1:
    image: acntechie/kafka
    container_name: friendly.kafka.1
    ports:
      - "9091:9091"
    environment:
      - KAFKA_BROKER_ID=1
      - KAFKA_PORT=9091
      - ZOOKEEPER_HOSTS=friendly.zookeeper.1:2181,friendly.zookeeper.2:2181,friendly.zookeeper.3:2181
    depends_on:
      - friendly.zookeeper.1
      - friendly.zookeeper.2
      - friendly.zookeeper.3
    networks:
    - kafka

  friendly.kafka.2:
    image: acntechie/kafka
    container_name: friendly.kafka.2
    ports:
      - "9092:9092"
    environment:
      - KAFKA_BROKER_ID=2
      - KAFKA_PORT=9092
      - ZOOKEEPER_HOSTS=friendly.zookeeper.1:2181,friendly.zookeeper.2:2181,friendly.zookeeper.3:2181
    depends_on:
      - friendly.zookeeper.1
      - friendly.zookeeper.2
      - friendly.zookeeper.3
    networks:
    - kafka

  friendly.kafka.3:
    image: acntechie/kafka
    container_name: friendly.kafka.3
    ports:
      - "9093:9093"
    environment:
      - KAFKA_BROKER_ID=3
      - KAFKA_PORT=9093
      - ZOOKEEPER_HOSTS=friendly.zookeeper.1:2181,friendly.zookeeper.2:2181,friendly.zookeeper.3:2181
    depends_on:
      - friendly.zookeeper.1
      - friendly.zookeeper.2
      - friendly.zookeeper.3
    networks:
    - kafka

  friendly.zookeeper.1:
    image: acntechie/zookeeper
    container_name: friendly.zookeeper.1
    environment:
      - ZOOKEEPER_ID=1
      - ZOOKEEPER_HOSTS=friendly.zookeeper.1:2888:3888,friendly.zookeeper.2:2888:3888,friendly.zookeeper.3:2888:3888
    networks:
    - kafka

  friendly.zookeeper.2:
    image: acntechie/zookeeper
    container_name: friendly.zookeeper.2
    environment:
      - ZOOKEEPER_ID=2
      - ZOOKEEPER_HOSTS=friendly.zookeeper.1:2888:3888,friendly.zookeeper.2:2888:3888,friendly.zookeeper.3:2888:3888
    networks:
    - kafka

  friendly.zookeeper.3:
    image: acntechie/zookeeper
    container_name: friendly.zookeeper.3
    environment:
      - ZOOKEEPER_ID=3
      - ZOOKEEPER_HOSTS=friendly.zookeeper.1:2888:3888,friendly.zookeeper.2:2888:3888,friendly.zookeeper.3:2888:3888
    networks:
    - kafka

networks:
  kafka:
    name: kafka
```

Then run ```docker-compose up -d``` to create and start all containers in daemon mode.

See example file ```docker-compose.cluster.yml```.
