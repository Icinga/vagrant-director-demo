class profile::icingaweb2 {
  include ::profile::webserver

  class { '::icingaweb2':
    install_method => 'package',
  }
  contain ::icingaweb2

  contain ::icingaweb2::mod::monitoring

  ensure_packages(['php5-curl'])
  Package['php5-curl'] ~> Class['apache::service']

  apache::custom_config { 'redirect':
    content => 'RedirectMatch ^/$ /icingaweb2',
  }

  create_resources('icingaweb2::config::resource_database', hiera_hash('icingaweb2::config::resource_database', {}))

  # ensure doc module
  #contain ::icingaweb2::mod::doc
  file { '/etc/icingaweb2/enabledModules/doc':
    ensure => link,
    target =>  '/usr/share/icingaweb2/modules/doc',
  }

  # icinga 2 docs
  exec { 'gunzip icinga2 docs':
    command => 'gunzip *.md.gz',
    path    => $::path,
    cwd     => '/usr/share/doc/icinga2/markdown',
  }

  file {
    '/etc/icingaweb2/enabledModules/icinga2':
      ensure => link,
      target =>  '/usr/share/icingaweb2/modules/icinga2';
    '/usr/share/icingaweb2/modules/icinga2':
      ensure => directory;
    '/usr/share/icingaweb2/modules/icinga2/doc':
      ensure => link,
      target => '/usr/share/doc/icinga2/markdown';
  }
}
