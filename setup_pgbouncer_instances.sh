#!/bin/bash

. .env

# Set the number of PgBouncer instances
NUM_INSTANCES=${NUM_INSTANCES:-3}

# Base port numbers
PGBOUNCER_BASE_PORT=6433
EXPORTER_BASE_PORT=9127

# Generate PgBouncer and exporter services
pgbouncers=""
exporters=""
export_targets=""

for i in $(seq 1 $NUM_INSTANCES)
do
  pgbouncer_port=$((PGBOUNCER_BASE_PORT + i - 1))
  exporter_port=$((EXPORTER_BASE_PORT + i - 1))

  pgbouncers="$pgbouncers
  pgbouncer$i:
    image: edoburu/pgbouncer:latest
    container_name: pgbouncer$i
    hostname: pgbouncer$i
    #ports:
    #  - \"${pgbouncer_port}:5432\"
    logging: *default_logging
    environment:
      <<: *default_environment
    restart: unless-stopped
    healthcheck: *default_healthcheck
    "

  exporters="$exporters
  pgbouncer_exporter$i:
    image: prometheuscommunity/pgbouncer-exporter
    container_name: pgbouncer_exporter$i
    hostname: pgbouncer_exporter$i
    environment:
      PGBOUNCER_EXPORTER_CONNECTION_STRING: \"postgres://${DB_USER}:${DB_PASSWORD}@pgbouncer$i:5432/pgbouncer?sslmode=disable\"
    logging: *default_logging
    depends_on:
      - pgbouncer$i
    #ports:
    #  - \"${exporter_port}:9127\"
    "
  export_targets="'pgbouncer_exporter$i:9127',"
done

# Build docker-compose.yml
cp docker-compose-template.yaml docker-compose.yaml
echo "$pgbouncers" >> docker-compose.yaml
echo "$exporters" >> docker-compose.yaml

# Build haproxy.cfg
cp haproxy/haproxy-template.cfg haproxy/haproxy.cfg
for i in $(seq 1 $NUM_INSTANCES)
do
  echo "    server pgbouncer$i pgbouncer$i:5432 check maxconn 0" >> haproxy/haproxy.cfg
done


# Update Prometheus configuration
cp prometheus/etc/prometheus.yml.template prometheus/etc/prometheus.yml
sed -i "s/\${EXPORTERS}/${export_targets}/g" prometheus/etc/prometheus.yml
sed -i "s/\${THANOS_REMOTE_WRITE_URL}/${THANOS_REMOTE_WRITE_URL}/g" prometheus/etc/prometheus.yml

