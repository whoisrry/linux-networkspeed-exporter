# Network Interface Speed Exporter

A Prometheus exporter that collects network interface speeds and statistics every second.

## Features

- Collects network interface speeds for all active interfaces
- Exposes metrics in Prometheus format
- Updates every second
- Skips loopback and down interfaces
- Collects both receive and transmit statistics
- Tracks errors, drops, and packet counts
- IP whitelist support for secure access
- Environment variable configuration support

## Installation

### Using Docker
```bash
# Build the image
docker build -t vyosexporter .

# Run the container with environment variables
docker run -d \
  --name vyosexporter \
  --network host \
  -p 8080:8080 \
  -e ALLOWED_IPS="192.168.1.100,10.0.0.50" \
  -e PORT=8080 \
  vyosexporter

# Or using docker-compose
docker-compose up -d
```

### Manual Installation
1. Make sure you have Go 1.21 or later installed
2. Clone this repository
3. Run `go mod tidy` to download dependencies
4. Build the application:
   ```bash
   go build
   ```

## Usage

Run the application:
```bash
# Allow all IPs (default)
./vyosexporter

# Allow specific IPs
./vyosexporter --allowed-ips="192.168.1.100,10.0.0.50"

# Change port
./vyosexporter --port=9090

# Combine options
./vyosexporter --allowed-ips="192.168.1.100" --port=9090
```

The exporter will start listening on the specified port (default: 8080). You can access the metrics at:
```
http://localhost:8080/metrics
```

## Configuration Options

### Command Line Arguments
- `--allowed-ips`: Comma-separated list of allowed IP addresses (default: "", allows all)
- `--port`: Port to listen on (default: "8080")

### Environment Variables
- `ALLOWED_IPS`: Comma-separated list of allowed IP addresses (default: "", allows all)
- `PORT`: Port to listen on (default: "8080")

## Metrics

The exporter exposes the following metrics:

### Network Speed
- `network_interface_speed_bits`: Network interface speed in bits per second (bps)
  - Labels:
    - `interface`: Name of the network interface (e.g., "eth0", "bond0.22")
    - `direction`: Either "receive" or "transmit"
  - Unit: bits per second (bps)
  - Example: 1000 bps = 1 Kbps, 1000000 bps = 1 Mbps

### Network Errors
- `network_interface_errors_total`: Total number of network interface errors
  - Labels:
    - `interface`: Name of the network interface
    - `direction`: Either "receive" or "transmit"

### Network Drops
- `network_interface_drops_total`: Total number of dropped packets
  - Labels:
    - `interface`: Name of the network interface
    - `direction`: Either "receive" or "transmit"

### Network Packets
- `network_interface_packets_total`: Total number of packets
  - Labels:
    - `interface`: Name of the network interface
    - `direction`: Either "receive" or "transmit"

## Example Metrics

Here's an example of the metrics you might see:

```
# Network speed metrics (in bits per second)
network_interface_speed_bits{interface="eth0",direction="receive"} 9876.0
network_interface_speed_bits{interface="eth0",direction="transmit"} 4542.4

# Network error metrics
network_interface_errors_total{interface="eth0",direction="receive"} 0
network_interface_errors_total{interface="eth0",direction="transmit"} 0

# Network drop metrics
network_interface_drops_total{interface="eth0",direction="receive"} 10056
network_interface_drops_total{interface="eth0",direction="transmit"} 0

# Network packet metrics
network_interface_packets_total{interface="eth0",direction="receive"} 565604971
network_interface_packets_total{interface="eth0",direction="transmit"} 523496319
```

## Prometheus Configuration

Add the following to your Prometheus configuration:

```yaml
scrape_configs:
  - job_name: 'network_speed'
    static_configs:
      - targets: ['localhost:8080']
```

## Example PromQL Queries

Here are some useful PromQL queries you can use in Grafana:

1. Total network speed (receive + transmit) for all interfaces (in bits per second):
```
sum(network_interface_speed_bits) by (interface)
```

2. Total errors across all interfaces:
```
sum(network_interface_errors_total) by (interface)
```

3. Total drops across all interfaces:
```
sum(network_interface_drops_total) by (interface)
```

4. Total packets across all interfaces:
```
sum(network_interface_packets_total) by (interface)
``` 