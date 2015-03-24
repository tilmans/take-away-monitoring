# statsd + graphite to go

Provision a virtual machine with vagrant and puppet to play around with statsd and graphite

## Details:

 * debian package for statsd (github.com/etsy) included
 * port forwardings enabled
 * graphite: http://localhost:8080/
 * Grafana: http://localhost:8081
 * statsd: 8125:udp

## Installation

```
git clone --recursive https://github.com/tilmans/take-away-monitoring.git
cd take-away-monitoring
vagrant up
open http://localhost:8080/
```

The default account is admin/admin

## Contributors

Created by jimdo https://github.com/Jimdo

For the list of contributors see the [commit history](https://github.com/tilmans/vagrant-statsd-graphite-puppet/commits/master)