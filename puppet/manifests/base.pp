Exec {
    path => ["/usr/bin", "/usr/sbin", '/bin']
}

Exec["apt-get-update"] -> Package <| |>

exec { "apt-get-update" :
    command => "/usr/bin/apt-get update",
    require => File["/etc/apt/preferences"]
}

file { "/etc/apt/preferences" :
    content => "
Package: *
Pin: release a=stable
Pin-Priority: 800

Package: *
Pin: release a=testing
Pin-Priority: 750

Package: *
Pin: release a=unstable
Pin-Priority: 650

Package: *
Pin: release a=oldstable
Pin-Priority: 600

Package: *
Pin: release a=experimental
Pin-Priority: 550
",
    ensure => present,
}

file { "/etc/issue":
    content => "
Welcome to the Graphite VM. To access the Graphite UI open http://localhost:8080 in your browser.

The Graphite account is admin/admin

To login via SSH: ssh -p 2222 vagrant@localhost
The login account is vagrant/vagrant.

Service ports:
Graphite Web: 8080
Grafana: 8081
SSH: 2222
Graphite/Carbon input: 2003 TCP, 2003 UDP
StatsD: 8125 UDP
",
    ensure => present
}

class { 'apache':
    default_vhost   => false,
}

include carbon
include statsd

class { 'grafana':
    datasources  => {
        'graphite' => {
            'type'    => 'graphite',
            'url'     => 'http://\'+window.location.hostname+\':8080',
            'default' => 'true'
        }, 
        'elasticsearch' => {
            'type'      => 'elasticsearch',
            'url'       => 'http://\'+window.location.hostname+\':9200',
            'index'     => 'grafana-dash',
            'grafanaDB' => 'true',
        },
    }
}

# Create Apache virtual host
apache::vhost { 'grafana.example.com':
    servername      => 'grafana.example.com',
    port            => 8081,
    docroot         => '/opt/grafana',
    error_log_file  => 'grafana-error.log',
    access_log_file => 'grafana-access.log',
    directories     => [
        {
            path            => '/opt/grafana',
            options         => [ 'None' ],
            allow           => 'from All',
            allow_override  => [ 'None' ],
            order           => 'Allow,Deny',
        }
    ]
}

$config_hash = {
  'ES_USER' => 'elasticsearch',
  'ES_GROUP' => 'elasticsearch',
}

class { 'java': }

class { 'elasticsearch': 
    init_defaults   => $config_hash,
    config          => {},
    manage_repo     => true,
    repo_version    => '1.4'
} 

elasticsearch::instance { 'take-away-monitoring': } 

elasticsearch::plugin{'lmenezes/elasticsearch-kopf':
  module_dir => 'kopf',
  instances  => 'take-away-monitoring'
}

