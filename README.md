Storm Swarm
===========

Docker configuration to build storm image for deployment of a [Parsely/streamparse](https://github.com/Parsely/streamparse) storm cluster using [docker](https://github.com/docker/docker) swarm 1.13.

Modified from [wurstmeister/docker-storm](https://github.com/wurstmeister/storm-docker) to include python dependencies in supervisor and nimbus for [streamparse](https://github.com/Parsely/streamparse) to work. Also the start up script has been modified for better automatic detection of the zookeeper and nimbus hosts to help with the deployment on docker swarm with an overlay network.

# Usage

Create a swarm and an overlay or bridge network `mynet`

```
# Secret for password: enter password you want and ctrl+D to exit 
docker secret create storm_password -


# we need zookeeper, ZOO_SERVERS env just appends to zoo.conf so we can get the auto purege in that way
docker service create --name zookeeper \
  --network mynet \
  -p 2181:2181 \
  -e "ZOO_SERVERS=autopurge.purgeInterval=12" \
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
  --secret=storm_password \
  ricmathie/storm-nimbus:0.0.2

# setup venvs and log folder for streamparse
docker secret create streamparse_requirements requirements.txt

docker service create -t --name storm_venv \
  --mode global \
  --mount type=bind,dst=/mount,src=/home \
  --secret=streamparse_requirements \
  ricmathie/storm-supervisor:0.0.2 \
  bash -c "mkdir -p /mount/streamparse/logs ;\
      mkdir -p /mount/streamparse/virtualenvs ; \
      cd /mount/streamparse/ ;\
      virtualenv virtualenvs --system-site-packages ;\
      . virtualenvs/bin/activate ;\
      cat /run/secrets/streamparse_requirements ;\
      pip install -r /run/secrets/streamparse_requirements; sh"

# give enough time for nimbus to achive running state
sleep 100

# nslookup tasks.nimbus | awk '/Address: / {print $2}' | nslookup | awk '/name = / {print substr($4, 1, length($4)-1)}'

docker service create --name storm_supervisor \
  --mode global \
  --network mynet \
    --mount type=bind,dst=/mount/streamparse,src=/home/streamparse \
  -e 'ZK_PORT_2181_TCP_ADDR=- zookeeper' \
  -e 'NIMBUS_HOSTS=tasks.nimbus' \
  -e 'HOST_INTERFACE=eth2' \
  --publish "6703:6703" \
  --publish "49080:8000" \
  --secret=storm_password \
  ricmathie/storm-supervisor:0.0.2

docker service create --name storm_ui \
  --network mercury \
  --constraint 'node.role == manager' \
  -e 'ZK_PORT_2181_TCP_ADDR=- zookeeper' \
  -e 'NIMBUS_HOSTS=tasks.nimbus' \
  -e 'HOST_INTERFACE=eth2' \
  --publish "49081:8080" \
  --secret=storm_password \
  ricmathie/storm-ui:0.0.2

# check venv sucseeded
docker service logs storm_venv
docker service rm storm_venv
```

# Configuration
see [storm/start-supervisor.sh](https://github.com/Richard-Mathie/storm_swarm/blob/master/storm/start-supervisor.sh) for how configuration and networking is set and storm.yaml is genorated.
```

```
