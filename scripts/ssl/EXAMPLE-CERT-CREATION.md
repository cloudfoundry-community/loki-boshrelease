# Example of the cert creation for the Loki/ Promtail/ Syslog setup

## Ca Certificates

### Loki

### Promtail

### Syslog

## Server Certificates

### Loki

### Promtail

### Syslog

## Client Certificates

### Loki

### Promtail

### Syslog

## Communication flow of the certificates and network routes

```mermaid
flowchart LR

A[Syslog Client e.g. CF system] -->|establish connection via port 6514| B(Syslog server)
B -->|forwards the message via port 9100| C(Promtail)
C -->|forwards the message via port 3100| D[Loki]
D <-->|scrapes the data via the HTTP API over port 3100| E[Monitoring tool e.g. Grafana/ Plutono]
```

