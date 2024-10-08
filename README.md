# Docker-based PgBouncer, HAProxy, and Prometheus Setup

This project sets up a Docker-based environment featuring PgBouncer instances with exporters, load balancing using HAProxy, and monitoring with Prometheus.

## Table of Contents

- [Environment Variables](#environment-variables)
- [Configuration Files](#configuration-files)
    - [HAProxy Configuration](#haproxy-configuration)
    - [Prometheus Configuration](#prometheus-configuration)
    - [Prometheus Entrypoint Script](#prometheus-entrypoint-script)
    - [Docker Compose Configuration](#docker-compose-configuration)
- [Usage](#usage)
- [Contributing](#contributing)
- [License](#license)

## Initial Setup

1. **Copy the example env file and edit it**:
   ```sh
   cp example.env .env
   ```
   Update the `.env` file with the necessary environment variables, including the number of PgBouncer instances.

2. **Run the setup script**:
   ```sh
   ./setup_pgbouncer_instance.sh
   ```
   This will configure the environment based on the number of PgBouncer instances specified in the `.env` file.

3. **Start the Docker Compose services**:
   ```sh
   docker-compose up -d
   ```

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

1. **Run the setup script to configure the environment with the desired number of PgBouncer instances**:
   ```sh
   ./setup_pgbouncer_instance.sh
   ```

2. **Start the Docker Compose services**:
   ```sh
   docker-compose up -d
   ```

3. **Access Prometheus**:

   Prometheus will be available at [http://localhost:9999](http://localhost:9999).

4. **Access HAProxy**:

   HAProxy will be available at [http://localhost:6432](http://localhost:6432).

Prometheus will scrape metrics from the PgBouncer exporter endpoints running on the designated port numbers.


## Contributing

Please fork the repository and use a feature branch. Pull requests are warmly welcome.

## License

This project is licensed under the MIT License - see the LICENSE file for details.