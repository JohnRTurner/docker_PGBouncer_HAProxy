# Docker Compose Sample for PgBouncer, HAProxy, and Prometheus Setup

This project sets up a Docker-based environment featuring variable number of PgBouncer instances with exporters, load balancing using HAProxy, and monitoring with Prometheus.  

## Table of Contents

- [Initial Setup](#initial-setup)
- [Configuration Files](#configuration-files)
    - [HAProxy Configuration](#haproxy-configuration)
    - [Prometheus Configuration](#prometheus-configuration)
    - [Docker Compose Configuration](#docker-compose-configuration)
- [Usage](#usage)
- [About the Docker](#about-the-dockers)
- [Contributing](#contributing)
- [License](#license)

## Initial Setup

1. **Prerequisites**:
   * Aiven Postgres database - will need connection parameters and credentials for step 2.
   * Aiven Thanos database - will need connection parameters and credentials for step 2.
     * Set the Postgres database to send metrics to Thanos
   * Aiven Grafana 
     * Setup to read from Thanos
     * Validate that dashboard works for Postgres database.

2. Prepare the machine for this code.  
   * The machine must have network access to:
     * The Aiven Postgres databases
     * The Aiven Thanos database
     * The client's that wish to use the PGBouncer for database connection management.
   * Must have git installed to pull this repo
   * Must have docker and docker-compose installed

3. Download this git repository to the machine you wish to deploy this on.

4. **Copy the example env file and edit it**:
   ```sh
   cd docker_PGBouncer_HAProxy
   cp example.env .env
   ```
   
5. Update the `.env` file with the desired environment variables, including the number of PgBouncer instances.

6. **Run the setup script**:
   ```sh
   ./setup_pgbouncer_instance.sh
   ```
   This will configure the environment based on the number of PgBouncer instances specified in the `.env` file.

7. **Start the Docker Compose services**:
   ```sh
   docker-compose up -d
   ```
8. **Add the Grafana Dashboards**:
   * Log into Grafana
   * For each of these dashboards (`12693`, `14022`) do the following:
     1. Press hamburg and open dashboards
     2. Click New Import
     3. Add the Dashboard ID and click the Load button.
     4. Select the Prometheus datasource(use the Thanos database from above).
     5. Click the import button to load the graph.


## Configuration Files

### Environment Variables `.env`

Example configuration file is in example.env.

The file .env can be quickly created by copying from example.env.

Please ensure to update these variables according to your requirements.


### HAProxy Configuration

File `haproxy.cfg` which will be auto-generated under `haproxy` directory.  

Note: Make change to `haproxy-template.cfg` to be permanent.


### Prometheus Configuration

File `prometheus.yml` will be auto-generated under `prometheus/etc` directory.

Note: Make change to `prometheus.yml.template` to be permanent.

### Docker Compose Configuration

File `docker-compose.yml` will be auto-generated.

Note: Make change to `docker-compose-template.yml` to be permanent.


## Usage

1. **Follow the Steps from the Initial Setup.**
   
2. **Start the Docker Compose services, if they are not running**:
   ```sh
   docker-compose up -d
   ```

3. **For Debugging can Directly Access Prometheus**:

   Prometheus will be available at `http://yourdockerhost:9999`...  Substitute your docker hostname.

4. **When properly configure, the dashboards are available in Grafana**

5. **The HAProxy statistics report can also be used for debugging**:

   HAProxy statistics report will be available at `http://yourdockerhost:8404`...  Substitute your docker hostname.
 
   Note: The username and password will be whatever is in haproxy.cfg; change as required.

6. **Connect to the database via PGBouncer through the HAProxy**:
   * For your connection string: 
     * Set the host to the docker hostname.
     * Set the port to 6432 (The port setup by HAProxy.)
     * Use the database username and password used to create the pgpool.

Prometheus will scrape metrics from the PgBouncer exporter endpoints running on the designated port numbers.

## About the Dockers:

* [edoburu/pgbouncer](https://github.com/edoburu/docker-pgbouncer) is used to run pgbouncer, a single threaded connection pool.  We use multiple pgbouncers to utilize parallel operations.

* [haproxytech/haproxy-alpine](https://github.com/haproxytech/haproxy-docker-alpine/tree/main) to load balance between the HAProxy servers.

* [prometheuscommunity/pgbouncer-exporter](https://github.com/prometheus-community/pgbouncer_exporter) enables collection of Prometheus statistics for PGBouncer.

* [prom/prometheus:latest](https://github.com/prometheus/prometheus) pulls data from the pgbouncer-exporter and directly from HAProxy.  It forwards it to Thanos which is used by Grafana to view metrics.

## Data Flow

```plaintext
                            +-------------------+
                            |     DB Clients    |
                            +---------+---------+
                                      |
                                      |
                           +----------v-----------+
                           |       HAProxy        |
                           +----------+-----------+
                                      |
          +---------------------------+-------------------------------+
          |                           |                               |
          |                           |                               |
+---------v----------+      +---------v----------+           +---------v----------+
| PgBouncer Instance |      | PgBouncer Instance |           | PgBouncer Instance |
|        1           |      |        2           |           |        3           |
+---------+----------+      +---------+----------+           +---------+----------+
          |                           |                               |
          +---------------------------+-------------------------------+
                                      |
                                      |
                           +----------v-----------+
                           |      PostgreSQL      |
                           +----------+-----------+
```

## Monitoring Flow

```plaintext
                           +----------------------+
                           |       HAProxy        |
                           +----------+-----------+
                                      |
          +---------------------------+-------------------------------+
          |                           |                               |
          |                           |                               |
+---------v----------+      +---------v----------+           +---------v----------+
| PgBouncer Instance |      | PgBouncer Instance |           | PgBouncer Instance |
|        1           |      |        2           |           |        N           |
+---------+----------+      +---------+----------+           +---------+----------+
          |                           |                               |
          |                           |                               |
+---------v----------+      +---------v----------+           +---------v----------+
| PgBouncer Exporter |      | PgBouncer Exporter |           | PgBouncer Exporter |
|        1           |      |        2           |           |        N           |
+---------+----------+      +---------+----------+           +---------+----------+
          |                           |                               |
          +---------------------------+-------------------------------+
                                      |
                                      +-------------------------------+
                                                                      |
+----------------------+                                   +----------v------------+
| HAProxy to Prometheus|                                   | PgBouncer Exporters to|
|                      |                                   |      Prometheus       | 
+---------+------------+                                   +----------+------------+
          |                                                           |
          +-----------------------------------------------------------+
          |                            
+---------v------------+                                   +-----------------------+
|     Prometheus       |                                   |      PostgreSQL       |
+---------+------------+                                   +----------+------------+
          |                                                           |
          +---------------------------+-------------------------------+
                                      |
                           +----------v-----------+
                           |        Thanos        |
                           +----------+-----------+
                                      |
                                      |
                           +----------v-----------+
                           |        Grafana       |
                           +----------------------+
```

## Contributing

Please fork the repository and use a feature branch. Pull requests are warmly welcome.

## License

This project is licensed under the MIT License - see the [LICENSE file](LICENSE.md) for details.