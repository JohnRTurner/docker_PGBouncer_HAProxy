# Prometheus

## Delete a job
Add command option --web.enable-admin-api to the docker-compose.yml as follows
```yaml
    command:
      - '--config.file=/etc/prometheus/prometheus.yml'
      - '--web.enable-admin-api'
```
then run:
```bash
#sudo apt install curl -y
curl -u admin -X POST -g 'http://prom:9090/api/v1/admin/tsdb/delete_series?match[]={job="node_192_168_2_110"}'
```
The default password is admin
