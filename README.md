# Loki BOSH Release

This is a [BOSH](http://bosh.io/) release for [Loki](https://grafana.com/loki), [Promtail](https://grafana.com/docs/loki/latest/send-data/promtail/) and the [Syslog plugin](https://grafana.com/docs/loki/latest/send-data/promtail/configuration/#syslog). The Bosh release supports for the complete system and all components GRPC and mTLS.  

## Prospects
It's planned to ship the release to the CloudFoundry community, and I'm currently in discussion with the community to create a public available bosh.io version.

## Prerequisites

Assuming you've installed `BOSH CLI` and have a running BOSH Director.

## Create a local Loki BOSH dev release

```
$ git clone https://github.com/cloudfoundry-community/loki-boshrelease.git

# Check if updates are available and maybe update the blobs (on scratch creation of the release, please use the --force parameter)
$ bash scripts/update-the-blobs.sh (--force)

# Adjust the Loki Manifest and add the corresponding release, finish the task with execution of the following commands
$ bosh create-release --force && bosh upload-release && bosh -d loki deploy manifests/loki.yml

# Check if everything is ready
$ bosh -d loki vms
Using environment '10.197.81.30' as client 'admin'

Task 318. Done

Deployment 'loki'

Instance                                       Process State  AZ  IPs           VM CID                                   VM Type  Active
loki/b96a577d-9e4c-48e3-a019-27c8a2b89e81      running        z1  10.197.81.50  vm-ee071874-d04a-422b-847a-a44c172d53b8  default  true

1 vms

Succeeded
```

## Create a local Loki BOSH final release

**Please execute the following commands:**
1. `bash scripts/update-the-blobs.sh` or use on scratch release creations `bash scripts/update-the-blobs.sh --force`
2. `bosh create-release --final --tarball loki-boshrelease.tgz`

## Configuration

```yaml
releases:
- name: loki
  version: <release_version>
  url: <release_url>
  sha1: <release_sha>

stemcells:
- alias: default
  os: ubuntu-jammy
  version: "1.83"

instance_groups:
- name: loki
  stemcell: default
  vm_type: small
  networks:
  - name: default
  azs: [z1]
  instances: 1
  jobs:
  - name: loki
    release: loki
    properties:
      loki:
          auth:
            enabled: false
          server:
            http_listen_address: localhost
            http_listen_port: 3100
          index:
            storage: boltdb
          object_store:
            storage: filesystem
          validation:
            enforce_metric_name: false
            reject_old_samples: true
            reject_old_samples_max_age: 672h
          retention:
            period: "168h"
          tls: false
      promtail:
          auth:
            enabled: false
          server:
            http_listen_address: localhost
            http_listen_port: 3100
          tls: false
          external_labels:
            - syslog: "input"
update:
  canaries: 1
  max_in_flight: 10
  canary_watch_time: 1000-30000
  update_watch_time: 1000-30000
  initial_deploy_az_update_strategy: serial
```

### Configuration with TLS

You can configure TLS by adding the certificates to the properties section

```yaml
      properties:
        loki:
            tls: true
            cert:
              crt: |
                -----BEGIN CERTIFICATE-----
                ...
                -----END CERTIFICATE-----
              key: |
                -----BEGIN PRIVATE KEY-----
                ...
                -----END PRIVATE KEY-----
        promtail:
            tls: true
            cert:
              crt: |
                -----BEGIN CERTIFICATE-----
                ...
                -----END CERTIFICATE-----
              key: |
                -----BEGIN PRIVATE KEY-----
                ...
                -----END PRIVATE KEY-----
```

### Configuration with mTLS

You can configure mTLS by adding the certificates to the properties section

```yaml
      properties:
        loki:
            mtls: true
            client_auth_type: "RequestClientCert"
            cert:
              ca: |
                -----BEGIN CERTIFICATE-----
                ...
                -----END CERTIFICATE-----
                -----BEGIN CERTIFICATE-----
                ...
                -----END CERTIFICATE-----
              crt: |
                -----BEGIN CERTIFICATE-----
                ...
                -----END CERTIFICATE-----
              key: |
                -----BEGIN PRIVATE KEY-----
                ...
                -----END PRIVATE KEY-----
        promtail:
          mtls: true
          client_auth_type: "RequestClientCert"
          cert:
            ca: |
              -----BEGIN CERTIFICATE-----
              ...
              -----END CERTIFICATE-----
              -----BEGIN CERTIFICATE-----
              ...
              -----END CERTIFICATE-----
            crt: |
              -----BEGIN CERTIFICATE-----
              ...
              -----END CERTIFICATE-----
            key: |
              -----BEGIN PRIVATE KEY-----
              ...
              -----END PRIVATE KEY-----
```

### More configuration parameters for Loki

You can find more available configuration parameters for Loki e.g. HTTP timeouts or the gRPC configuration inside the [spec](jobs/loki/spec) file.

### More configuration parameters for Promtail

You can find more available configuration parameters for Promtail e.g. HTTP timeouts or the gRPC configuration inside the [spec](jobs/promtail/spec) file.

## Tear Down the deployment

To remove the deployment:

```
$ bosh -d loki delete-deployment
```

## Clap your hands for the dependencies

The Loki Bosh release wouldn't be possible if it weren't for the great projects and tools they depend on. Please check out the list below and clap your hands for them.

### Loki
[Loki](https://github.com/grafana/loki) is a highly available, horizontally scalable, multi-tenant log aggregation system inspired by Prometheus system. It's licensed under the [AGPL-3.0 license](https://github.com/grafana/loki?tab=AGPL-3.0-1-ov-file#readme).

### Promtail
[Promtail](https://github.com/grafana/loki) is an agent which forward the content of logs to a Loki instance. It's licensed under the [AGPL-3.0 license](https://github.com/grafana/loki?tab=AGPL-3.0-1-ov-file#readme).

### JQ
[JQ](https://github.com/jqlang/jq) is a command-line JSON processor. It's licensed under the [[MIT license](https://github.com/jqlang/jq/blob/master/COPYING).

## Contribution
If you would like to contribute something, have an improvement request, or want to make a change inside the code, please open a pull request.

## Support
If you need support, or you encounter a bug, please don't hesitate to open an issue.

## License
This product is available under the Apache 2.0 license.