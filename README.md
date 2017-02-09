Storm Swarm
===========

Docker configuration to build storm image for devstack deployment.

Modified from [wurstmeister/docker-storm](https://github.com/wurstmeister/storm-docker) to include python dependencies in supervisor and nimbus for [streamparse](https://github.com/Parsely/streamparse) to work. Also the start up script has been modified for better automatic detection of the zookeeper and nimbus hosts to help with the deployment on docker swarm with an overlay network.

# Usage

Create a swarm and an overlay or bridge network `mynet`

```
docker service create --name zookeeper \
  --network mynet \
  -p 2181:2181 \
  zookeeper:3.4.9


docker service create --name nimbus \
  --network mynet \
  -e 'ZK_PORT_2181_TCP_ADDR=- zookeeper' \
  -e 'NIMBUS_HOSTS=tasks.nimbus' \
  -e 'HOST_INTERFACE=eth2' \
  --publish "3773:3773" \
  --publish "3772:3772" \
  --publish "6627:6627" \
  --publish "49082:8000" \
  ricmathie/storm-nimbus:0.0.2

# give enough time for nimbus to achive running state
sleep 100

# nslookup tasks.nimbus | awk '/Address: / {print $2}' | nslookup | awk '/name = / {print substr($4, 1, length($4)-1)}'

docker service create --name storm_supervisor \
  --mode global \
  --network mynet \
  -e 'ZK_PORT_2181_TCP_ADDR=- zookeeper' \
  -e 'NIMBUS_HOSTS=tasks.nimbus' \
  -e 'HOST_INTERFACE=eth2' \
  --publish "6703:6703" \
  --publish "49080:8000" \
  ricmathie/storm-supervisor:0.0.2

docker service create --name storm_ui \
  --network mercury \
  --constraint 'node.role == manager' \
  -e 'ZK_PORT_2181_TCP_ADDR=- zookeeper' \
  -e 'NIMBUS_HOSTS=tasks.nimbus' \
  -e 'HOST_INTERFACE=eth2' \
  --publish "49081:8080" \
  ricmathie/storm-ui:0.0.2
```

