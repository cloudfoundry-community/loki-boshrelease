# Loki BOSH Release

This is a [BOSH](http://bosh.io/) release for [Loki](https://grafana.com/loki).

#TODO Download and upload blobs documentation

## Prerequisites

Assuming you've installed `BOSH CLI` and have a running BOSH Director.

## Create a local Loki BOSH dev release

```
$ git clone https://github.com/ZPascal/loki-boshrelease.git

# Check if updates are available and maybe update the blobs
$ bash scripts/update-the-blobs.sh

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

```bash
bash scripts/update-the-blobs.sh
bosh create-release --final --tarball fluentd-boshrelease.tgz
```

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

## Tear Down the deployment

To remove the deployment:

```
$ bosh -d loki delete-deployment
```
