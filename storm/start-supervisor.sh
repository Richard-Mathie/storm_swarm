#!/bin/bash

hosts_lookup_yaml() {
  nslookup $1 | awk '/^Address: / {print " -", "\""$2"\""}'
}
hosts_lookup_csv() {
  nslookup $1 | awk '/^Address: / {print "\""$2"\""}' | paste -d, -s -
}

hosts_to_yaml() {
  awk -v hosts="$1" 'BEGIN {$0=hosts; for (i=1;i<=NF;i++) {print " -", "\""$i"\""}}'
}

replace_or_append() {
  grep -q "^$1" $3 && sed -i "s/^$1.*/$1: $2/" $3 || echo "$1: $2" >> $3
}

# : ${HOST_COMMAND="hostname --ip-address | awk '{print \$1}'"}
 : ${HOST_INTERFACE="eth0"}
 : ${HOST_COMMAND="ip r | awk '{ ip[\$3] = \$NF } END { print ( \"$HOST_INTERFACE\" in ip ? ip[\"$HOST_INTERFACE\"] : ip[\"eth0\"] ) }'"}

 : ${ZOOKEEPER_HOSTS="tasks.zookeeper.mercury"}
 : ${ZOOKEEPER_COMMAND="hosts_to_yaml $ZOOKEEPER_HOSTS"}

 : ${NIMBUS_HOSTS="tasks.nimbus.mercury"}
 : ${NIMBUS_COMMAND="hosts_to_yaml $NIMBUS_HOSTS"}
 : ${DRPC_COMMAND="hosts_to_yaml $NIMBUS_HOSTS"}

 : ${STORM_PASSWORD="default_storm_password"}
 
export ZOOKEEPER_IP=${ZK_PORT_2181_TCP_ADDR:=$(eval $ZOOKEEPER_COMMAND)}
export NIMBUS_IP=${NIMBUS_PORT_6627_TCP_ADDR:=$(eval $NIMBUS_COMMAND)}
export DRPC_IP=${DRPC_PORT_6627_TCP_ADDR:=$(eval $DRPC_COMMAND)}
export HOST_IP=$(eval $HOST_COMMAND)

# password secrets
if [ -f /run/secrets/storm_password ]; then
   echo /run/secrets/storm_password | chpasswd
else
   echo $STORM_PASSWORD | chpasswd
fi

sed -i -e "s/%zookeeper%/$ZOOKEEPER_IP/g" $STORM_HOME/conf/storm.yaml
sed -i -e "s/%nimbus_seeds%/$NIMBUS_IP/g" $STORM_HOME/conf/storm.yaml
sed -i -e "s/%nimbus_servers%/$DRPC_IP/g" $STORM_HOME/conf/storm.yaml

replace_or_append storm.local.hostname "$HOST_IP" $STORM_HOME/conf/storm.yaml

supervisord
