#!/bin/bash
hosts_lookup_yaml() {
  nslookup $1 | awk '/^Address: / {print " -", "\""$2"\""}'
}
hosts_lookup_csv() {
  nslookup $1 | awk '/^Address: / {print "\""$2"\""}' | paste -d, -s -
}
# : ${HOST_COMMAND="hostname --ip-address | awk '{print \$1}'"}
 : ${HOST_INTERFACE="eth0"}
 : ${HOST_COMMAND="ip r | awk '{ ip[\$3] = \$NF } END { print ( \"$HOST_INTERFACE\" in ip ? ip[\"$HOST_INTERFACE\"] : ip[\"eth0\"] ) }'"}

 : ${ZOOKEEPER_HOSTS="tasks.zookeeper.mercury"}
 : ${ZOOKEEPER_COMMAND="hosts_lookup_yaml $ZOOKEEPER_HOSTS"}

export ZOOKEEPER_IP=${ZK_PORT_2181_TCP_ADDR:=$(eval $ZOOKEEPER_COMMAND)}
export HOST_IP=$(eval $HOST_COMMAND)

sed -i -e "s/%zookeeper%/$ZOOKEEPER_IP/g" $STORM_HOME/conf/storm.yaml
sed -i -e "s/%nimbus_seeds%/\"$HOST_IP\"/g" $STORM_HOME/conf/storm.yaml
sed -i -e "s/%nimbus_servers%/ - \"$HOST_IP\"/g" $STORM_HOME/conf/storm.yaml

echo "storm.local.hostname: $HOST_IP" >> $STORM_HOME/conf/storm.yaml
echo "nimbus.thrift.max_buffer_size: 20480000" >> $STORM_HOME/conf/storm.yaml
supervisord
