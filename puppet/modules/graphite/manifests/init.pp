class graphite($version = '0.9.10') {

  $build_dir = "/tmp"

  $webapp_url = "https://github.com/graphite-project/graphite-web/archive/${version}.tar.gz"

  $webapp_loc = "$build_dir/graphite-web.tar.gz"

  $python_packages = [ 'python-ldap', 'python-cairo', 'python-django', 'python-django-tagging', 
                      'python-simplejson', 'libapache2-mod-python', 'python-memcache', 'python-pysqlite2',
                      'python-support']

  package { $python_packages:
    ensure => latest,
  } ->

  class { 'apache::mod::python':} ->

  class { 'apache::mod::headers':} ->

  package { "python-whisper":
    ensure   => installed,
    provider => dpkg,
    source   => "/vagrant/python-whisper_${version}-1_all.deb",
  } ->

  exec { "download-graphite-webapp":
    command => "wget -O $webapp_loc $webapp_url",
    creates => "$webapp_loc"
  } ->

  exec { "unpack-webapp":
    command => "tar -zxvf $webapp_loc",
    cwd => $build_dir,
    subscribe=> Exec[download-graphite-webapp],
    refreshonly => true,
  } ->

  exec { "install-webapp":
    command => "python setup.py install",
    cwd => "$build_dir/graphite-web-${version}",
    creates => "/opt/graphite/webapp"
  } ->

    apache::vhost { 'graphite.example.com':
      servername      => 'graphite.example.com',
      port            => 80,
      priority        => 25,
      docroot         => '/opt/graphite/webapp',
      error_log_file  => 'graphite-error.log',
      access_log_file => 'graphite-access.log',      
  } ->

  file { [ "/opt/graphite/storage", "/opt/graphite/storage/whisper" ]:
    owner => "www-data",
    subscribe => Exec["install-webapp"],
    mode => "0775",
  } ->

  exec { "init-db":
    command => "python manage.py syncdb --noinput",
    cwd => "/opt/graphite/webapp/graphite",
    creates => "/opt/graphite/storage/graphite.db",
    subscribe => File["/opt/graphite/storage"],
  } ->

  file { "/opt/graphite/webapp/graphite/initial_data.json" :
    ensure => present,
    content => '
[
  {
    "pk": 1, 
    "model": "auth.user", 
    "fields": {
      "username": "admin", 
      "first_name": "", 
      "last_name": "", 
      "is_active": true, 
      "is_superuser": true, 
      "is_staff": true, 
      "last_login": "2011-09-20 17:02:14", 
      "groups": [], 
      "user_permissions": [], 
      "password": "sha1$1b11b$edeb0a67a9622f1f2cfeabf9188a711f5ac7d236", 
      "email": "root@example.com", 
      "date_joined": "2011-09-20 17:02:14"
    }
  }
]'
  } ->

  file { "/opt/graphite/storage/graphite.db" :
    owner => "www-data",
    mode => "0664",
    subscribe => Exec["init-db"],
  } ->

  file { "/opt/graphite/storage/log/webapp/":
    ensure => "directory",
    owner => "www-data",
    mode => "0775",
    subscribe => Exec["install-webapp"],
  } ->

  file { "/opt/graphite/webapp/graphite/local_settings.py" :
    source => "puppet:///modules/graphite/local_settings.py",
    ensure => present,
  }

  concat::fragment { "graphite-fragment":
    target  => '25-graphite.example.com.conf',
    order   => 11,
    content => '
          <Location "/">
                  SetHandler python-program
                  PythonPath "[\'/opt/graphite/webapp\'] + sys.path"
                  PythonHandler django.core.handlers.modpython
                  SetEnv DJANGO_SETTINGS_MODULE graphite.settings
                  PythonDebug Off
                  PythonAutoReload Off
                  Header set Access-Control-Allow-Origin "*"
          </Location>

          <Location "/content/">
                  SetHandler None
          </Location>

          <Location "/media/">
                  SetHandler None
          </Location>

          # NOTE: In order for the django admin site media to work you
          # must change @DJANGO_ROOT@ to be the path to your django
          # installation, which is probably something like:
          # /usr/lib/python2.6/site-packages/django
          Alias /media/ "@DJANGO_ROOT@/contrib/admin/media/"
    ',
  }

 anchor { 'graphite::end': }

}
