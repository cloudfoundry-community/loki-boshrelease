#!/bin/sh

# Switch the directory
echo "Switch the directory"
path=$(pwd)/config
cd certs

# Create the Syslog ca
echo "Create the Syslog ca"
openssl req -new -x509 -sha256 -newkey rsa:4096 -nodes -keyout ca_syslog.key -out ca_syslog.crt -days 3650 \
-extensions ext \
-config $path/ca_syslog.conf

# Create the Loki ca
echo "Create the Loki ca"
openssl req -new -x509 -sha256 -newkey rsa:4096 -nodes -keyout ca_loki.key -out ca_loki.crt -days 3650 \
-extensions ext \
-config $path/ca_loki.conf

# Create the Promtail ca
echo "Create the Promtail ca"
openssl req -new -x509 -sha256 -newkey rsa:4096 -nodes -keyout ca_promtail.key -out ca_promtail.crt -days 3650 \
-extensions ext \
-config $path/ca_promtail.conf

# Create the server certificates
echo "Create the Loki server certificates"
openssl genrsa -out loki.key 4096
openssl req -new -key loki.key -out loki.csr \
-extensions v3_req \
-config $path/server_loki.conf
openssl x509 -inform der -req -days 1825 -in loki.csr -CA ca_loki.crt -CAkey ca_loki.key -CAcreateserial -out loki.pem -extensions v3_req -extfile $path/server_loki.conf

# Create the Promtail certificates
echo "Create the Promtail server certificates"
openssl genrsa -out promtail.key 4096
openssl req -new -key promtail.key -out promtail.csr \
-extensions v3_req \
-config $path/server_promtail.conf
openssl x509 -inform der -req -days 1825 -in promtail.csr -CA ca_promtail.crt -CAkey ca_promtail.key -CAcreateserial -out promtail.pem -extensions v3_req -extfile $path/server_promtail.conf

# Create the Syslog certificates
echo "Create the Syslog server certificates"
openssl genrsa -out syslog.key 4096
openssl req -new -key syslog.key -out syslog.csr \
-extensions v3_req \
-config $path/server_syslog.conf
openssl x509 -inform der -req -days 1825 -in syslog.csr -CA ca_syslog.crt -CAkey ca_syslog.key -CAcreateserial -out syslog.pem -extensions v3_req -extfile $path/server_syslog.conf

# Create the client certificates
echo "Create the Grafana client certificates"
openssl genrsa -out grafana_client.key 4096
openssl req -new -key grafana_client.key -out grafana_client.csr \
-extensions v3_req \
-config $path/client_loki.conf
openssl x509 -req -days 1825 -in grafana_client.csr -CA ca_loki.crt -CAkey ca_loki.key -CAcreateserial -out grafana_client.crt -extensions v3_req -extfile $path/client_loki.conf

echo "Create the Loki client certificates"
openssl genrsa -out loki_client.key 4096
openssl req -new -key loki_client.key -out loki_client.csr \
-extensions v3_req \
-config $path/client_promtail.conf
openssl x509 -req -days 1825 -in loki_client.csr -CA ca_promtail.crt -CAkey ca_promtail.key -CAcreateserial -out loki_client.crt -extensions v3_req -extfile $path/client_promtail.conf

echo "Create the UPS client certificates"
openssl genrsa -out ups_client.key 4096
openssl req -new -key ups_client.key -out ups_client.csr \
-extensions v3_req \
-config $path/client_syslog.conf
openssl x509 -req -days 1825 -in ups_client.csr -CA ca_syslog.crt -CAkey ca_syslog.key -CAcreateserial -out ups_client.crt -extensions v3_req -extfile $path/client_syslog.conf