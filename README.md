# Docker Compose Sample for PgBouncer, HAProxy, and Prometheus Setup

This project sets up a Docker-based environment featuring variable number of PgBouncer instances with exporters, load balancing using HAProxy, and monitoring with Prometheus.  

## Table of Contents

- [Initial Setup](#initial-setup)
  - [Prerequisites](#prerequisites)
  - [Setup Steps](#setup-steps)
  - [Setup Grafana Dashboards](#setup-grafana-dashboards)
- [Configuration Files](#configuration-files)
- [Usage](#usage)
- [Dockers](#dockers)
- [Data Flow](#data-flow)
- [Monitoring Flow](#monitoring-flow)
- [Contributing](#contributing)
- [License](#license)
- [Contact](#contact)

## Initial Setup

### Prerequisites

1. **Aiven Services:**
    * **PostgreSQL Database:**
        - Obtain connection parameters and credentials.
    * **Thanos Database:**
        - Obtain connection parameters and credentials.
        - Configure PostgreSQL to send metrics to Thanos.
    * **Grafana:**
        - Set up to read from Thanos.
        - Validate that the dashboard works for the PostgreSQL database.

2. **Machine Requirements:**
    * Network access to:
        - Aiven PostgreSQL databases.
        - Aiven Thanos database.
        - Clients requiring PgBouncer for database connection management.
    * Installed software:
        - Git for pulling this repository.
        - Docker and Docker Compose for container management.

### Setup Steps

1. **Clone the Repository:**
    ```sh
    git clone https://github.com/yourusername/yourproject.git
    cd yourproject
    ```

2. **Copy and Edit the Example Environment File:**
    ```sh
    cp example.env .env
    ```
    - Update the `.env` file with the desired environment variables, including the number of PgBouncer instances.

3. **Run the Setup Script:**
    ```sh
    ./setup_pgbouncer_instance.sh
    ```
    - This script configures the environment based on the `.env` file settings.

4. **Start the Docker Compose Services:**
    ```sh
    docker-compose up -d
    ```

### Setup Grafana Dashboards

1. Log into Grafana.
2. For each dashboard (`12693`, `14022`):
    - Go to Dashboards, click "New Import", and enter the Dashboard ID.
    - Select the Prometheus datasource (use the Thanos datasource).
    - Click "Import" to load the dashboard.



## Configuration Files

### Environment Variables `.env`

- **File:** `.env`
- **Example:** `example.env`
- Update the variables in `.env` according to your specific requirements.


### HAProxy Configuration

- **File:** `haproxy/haproxy.cfg` (auto-generated)
- **Template:** `haproxy/haproxy-template.cfg`


### Prometheus Configuration

- **File:** `prometheus/etc/prometheus.yml` (auto-generated)
- **Template:** `prometheus/etc/prometheus.yml.template`

### Docker Compose Configuration

- **File:** `docker-compose.yml` (auto-generated)
- **Template:** `docker-compose-template.yml`


## Usage

1. **Start the Docker Compose Services**:
   ```sh
   docker-compose up -d
   ```

2. **Access Prometheus**: 
   - Visit `http://yourdockerhost:9999`...  Substitute your docker hostname.

3. **Access Grafana Dashboards:**
   - Once configured correctly, dashboards will be available.

4. **Access HAProxy Statistics**:
   - HAProxy statistics report will be available at `http://yourdockerhost:8404`...  Substitute your docker hostname. (use credentials from `haproxy.cfg`).
 
5. **Connect to the database via PGBouncer through the HAProxy**:
   - Set the host to the docker hostname.
   - Set the port to 6432 (The port setup by HAProxy.)
   - Use the same database username and password used to create the pgpool.

Prometheus will scrape metrics from the PgBouncer exporter endpoints running on the designated port numbers.

## Dockers:

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

1. Fork the repository.
2. Create your feature branch (`git checkout -b feature/AmazingFeature`).
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`).
4. Push to the branch (`git push origin feature/AmazingFeature`).
5. Open a pull request.

## License

Distributed under the MIT License. See `LICENSE.md` for more information.

## Contact

John Turner - [jrt13a@yahoo.com](mailto:jrt13a@yahoo.com)

Project Link: [https://github.com/JohnRTurner/docker_PGBouncer_HAProxy](https://github.com/JohnRTurner/docker_PGBouncer_HAProxy) 

```plaintext
                                                                                          
                                  .:..               .:..                                 
                              .=+******+-.       .=+******+-                              
                             =***+=+******:     =***+=+******:                            
                            -***:  +*******:   =***: .********.                           
                            +**=   :+**+***=   +**-   :+**+***-                           
                            =***.      :***:   =**+.      -***.                           
                             =***=-::-=***=    .+***=:::-+***-                            
                              :+********=:       -+********=.                             
                                .::--:.            .::--:.                                
                  .-=+++++-.        .::---=======--::..        :=+***+=:                  
                .=******+-.   .:==+*********************+=-:.   :=*******-                
                .-+***=.  .:=+*******************************+=:   :+***=:                
                  .:-.  :=*************+-:::::::::-**************=.  :=:                  
              .-=++-  :=****************:         =****************=  .+*+=:              
             -+***-  :+*****************+-.    .:=******************+. .****+:            
            -*****. .***********************+++**********************=  -****+.           
            +****+  :************************************************+  :*****=           
            .:.:-+. .+***********************************************=  -=::::.           
               .+*=  :+*********************************************+. .**=               
               ++**-  .-:::.:-=+***************************+=-::::-:  .+***-              
               ++**=.  :--==-:. .=**********************+-  .--==--.  -+***=              
               -++: .=+*******++: .+*******************=. -+********+- .=**:              
                -: :++**********+- .+*****************= .+************+. -:               
                   +**************.  .:::--------:::..  -**************-                  
                  .+******+-:.:-++:                     =*=-:.:=*******=                  
                   =+*****=      .                      ..     .*******:                  
                    -+****+.                                   -*****+:                   
                     .-=++++:                                .=***+=:                     
                                                                                          

```
