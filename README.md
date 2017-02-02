Storm Swarm
===========

Docker configuration to build storm image for devstack deployment.

Modified from [wurstmeister/docker-storm](https://github.com/wurstmeister/storm-docker) to include python dependencies in supervisor and nimbus for [streamparse](https://github.com/Parsely/streamparse) to work. Also the start up script has been modified for better automatic detection of the zookeeper and nimbus hosts to help with the deployment on docker swarm with an overlay network.
