class profile::icinga2 {
  contain ::vagrantssl
  contain ::icinga2

  contain ::icinga2::feature::idomysql
  contain ::icinga2::feature::api
  contain ::icinga2::feature::command

  Class['::vagrantssl'] -> Class['::icinga2::feature::api']

  file { 'icinga2 conf.d':
    ensure  => 'directory',
    path    => '/etc/icinga2/conf.d',
    purge   => true,
    recurse => true,
    force   => true,
  }

  create_resources('icinga2::object::apiuser', hiera_hash('icinga2::object::apiuser', { }),
    {
      target => '/etc/icinga2/conf.d/apiusers.conf',
    }
  )

  ensure_packages(['monitoring-plugins', 'monitoring-plugins-standard'])
}
