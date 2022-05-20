#!/bin/bash

if [ -f /etc/nginx/default.d/roboshop.conf ]; then
  sed -i -e 's/ENV/dev/' /etc/nginx/default.d/roboshop.conf /etc/filebeat/filebeat.yml
  systemctl restart nginx
  systemctl restart filebeat
  exit
fi

COMPONENT=$(ls /home/roboshop/)
GET_PASS() {
  aws secretsmanager get-secret-value --secret-id dev/roboshop/secrets | jq .SecretString | sed -e 's|\\||g' -e 's|^"||' -e 's|"$||' | jq .${1} | xargs
}
DOCUMENTDB_MASTER_USERNAME=$(GET_PASS DOCUMENTDB_MASTER_USERNAME)
DOCUMENTDB_MASTER_PASSWORD=$(GET_PASS DOCUMENTDB_MASTER_PASSWORD)
RABBITMQ_USERNAME=$(GET_PASS RABBITMQ_USERNAME)
RABBITMQ_PASSWORD=$(GET_PASS RABBITMQ_PASSWORD)
MONGODB_ENDPOINT=$(aws docdb describe-db-clusters --db-cluster-identifier  roboshop-dev  --output table | grep -w Endpoint | awk '{print $4}')

sed -i -e 's/ENV/dev/' -e "s/DOCUMENTDB_MASTER_USERNAME/${DOCUMENTDB_MASTER_USERNAME}/" -e "s/DOCUMENTDB_MASTER_PASSWORD/${DOCUMENTDB_MASTER_PASSWORD}/" -e "s/RABBITMQ_USERNAME/${RABBITMQ_USERNAME}/" -e "s/RABBITMQ_PASSWORD/${RABBITMQ_PASSWORD}/" -e "s/MONGODB_ENDPOINT/${MONGODB_ENDPOINT}/" /etc/systemd/system/${COMPONENT}.service /etc/filebeat/filebeat.yml

systemctl daemon-reload
systemctl restart ${COMPONENT}
systemctl restart filebeat
