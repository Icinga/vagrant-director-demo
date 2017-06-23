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
}
