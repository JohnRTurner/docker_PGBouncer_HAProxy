# Docker-based PgBouncer, HAProxy, and Prometheus Setup

This project sets up a Docker-based environment featuring  X PgBouncer instances with exporters, load balancing using HAProxy, and monitoring with Prometheus.  
This 

## Table of Contents

- [Initial Setup](#initial-setup)
- [Environment Variables](#environment-variables)
- [Configuration Files](#configuration-files)
    - [HAProxy Configuration](#haproxy-configuration)
    - [Prometheus Configuration](#prometheus-configuration)
    - [Docker Compose Configuration](#docker-compose-configuration)
- [Usage](#usage)
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

2. **Copy the example env file and edit it**:
   ```sh
   cp example.env .env
   ```
   
3. Update the `.env` file with the desired environment variables, including the number of PgBouncer instances.

4. **Run the setup script**:
   ```sh
   ./setup_pgbouncer_instance.sh
   ```
   This will configure the environment based on the number of PgBouncer instances specified in the `.env` file.

5. **Start the Docker Compose services**:
   ```sh
   docker-compose up -d
   ```
6. **Add the Grafana Dashboards**:
   * Log into Grafana
   * For each of these dashboards (`12693`, `14022`) do the following:
     1. Press hamburg and open dashboards
     2. Click New Import
     3. Add the Dashboard ID and click the Load button.
     4. Select the Prometheus datasource(use the Thanos database from above).
     5. Click the import button to load the graph.

## Environment Variables

Example configuration file is in example.env.  

The file .env can be quickly created by copying from example.env.

Please ensure to update these variables according to your environment.

## Configuration Files

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


## Contributing

Please fork the repository and use a feature branch. Pull requests are warmly welcome.

## License

This project is licensed under the MIT License - see the LICENSE file for details.