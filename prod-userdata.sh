#!/bin/bash

if [ -f /etc/nginx/default.d/roboshop.conf ]; then
  sed -i -e 's/ENV/prod/' /etc/nginx/default.d/roboshop.conf /etc/filebeat/filebeat.yml
  systemctl restart nginx
  systemctl restart filebeat
  exit
fi

COMPONENT=$(ls /home/roboshop/)
GET_PASS() {
  aws secretsmanager get-secret-value --secret-id prod/roboshop/secrets | jq .SecretString | sed -e 's|\\||g' -e 's|^"||' -e 's|"$||' | jq .${1}
}
DOCUMENTDB_MASTER_USERNAME=$(GET_PASS DOCUMENTDB_MASTER_USERNAME)
DOCUMENTDB_MASTER_PASSWORD=$(GET_PASS DOCUMENTDB_MASTER_PASSWORD)
RABBITMQ_USERNAME=$(GET_PASS RABBITMQ_USERNAME)
RABBITMQ_PASSWORD=$(GET_PASS RABBITMQ_PASSWORD)

sed -i -e 's/ENV/prod/' -e "s/DOCUMENTDB_MASTER_USERNAME/${DOCUMENTDB_MASTER_USERNAME}/" -e "s/DOCUMENTDB_MASTER_PASSWORD/${DOCUMENTDB_MASTER_PASSWORD}" -e "s/RABBITMQ_USERNAME/${RABBITMQ_USERNAME}/" -e "s/RABBITMQ_PASSWORD/${RABBITMQ_PASSWORD}/" /etc/systemd/system/${COMPONENT}.service /etc/filebeat/filebeat.yml

systemctl daemon-reload
systemctl restart ${COMPONENT}
systemctl restart filebeat
