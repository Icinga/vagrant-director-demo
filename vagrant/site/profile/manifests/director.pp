class profile::director {
  require ::profile::mysql
  require ::profile::icinga2
  require ::profile::icingaweb2

  $_version = '1.3.1'
  $_install_path = '/usr/share/icingaweb2/modules/director'
  $_install_path_fileshipper = '/usr/share/icingaweb2/modules/fileshipper'
  $_config_dir = '/etc/icingaweb2/modules/director'

  file {
    'icinga director':
      ensure => 'directory',
      path   => $_install_path,
      owner  => 'root',
      group  => 'root',
      mode   => '0644';
    'icinga fileshipper':
      ensure => 'directory',
      path   => $_install_path_fileshipper,
      owner  => 'root',
      group  => 'root',
      mode   => '0644';
  }

  archive { "/opt/director-${_version}.tar.gz":
    ensure          => present,
    source          => "https://github.com/Icinga/icingaweb2-module-director/archive/v${_version}.tar.gz",
    extract         => true,
    extract_path    => $_install_path,
    extract_command => 'tar xf %s --strip-components=1',
    creates         => "${_install_path}/module.info",
    user            => 'root',
    group           => 'root',
  }

  archive { "/opt/fileshipper.tar.gz":
    ensure          => present,
    source          => 'https://github.com/Icinga/icingaweb2-module-fileshipper/archive/master.tar.gz',
    extract         => true,
    extract_path    => $_install_path_fileshipper,
    extract_command => 'tar xf %s --strip-components=1',
    creates         => "${_install_path_fileshipper}/module.info",
    user            => 'root',
    group           => 'root',
  }

  file {
    'icingaweb2 module enable director':
      ensure => link,
      path   => '/etc/icingaweb2/enabledModules/director',
      target => $_install_path;
    'icingaweb2 module enable fileshipper':
      ensure => link,
      path   => '/etc/icingaweb2/enabledModules/fileshipper',
      target => $_install_path_fileshipper;
    'icinga director config':
      ensure => directory,
      path   => $_config_dir,
      owner  => $icingaweb2::config_user,
      group  => $icingaweb2::config_group,
      mode   => $icingaweb2::config_dir_mode;
  }

  Exec {
    path => $::path,
  }

  $_kickstart = "[config]\nendpoint = ${::fqdn}\nusername = director\npassword = director\n"

  exec { 'Icinga Director DB migration':
    command => 'icingacli director migration run',
    onlyif  => 'icingacli director migration pending',
  } ->

  file { 'icinga director config kickstart':
    ensure  => file,
    path    => "${_config_dir}/kickstart.ini",
    owner   => $icingaweb2::config_user,
    group   => $icingaweb2::config_group,
    mode    => $icingaweb2::config_dir_mode,
    content => $_kickstart,
  } ->

  exec { 'Icinga Director Kickstart':
    command => 'icingacli director kickstart run',
    onlyif  => 'icingacli director kickstart required',
  }

  ensure_packages(['php-pear', 'php5-dev', 'libyaml-dev'])

  exec { 'install pecl yaml':
    command => 'pecl install yaml',
    creates => '/usr/lib/php5/20131226/yaml.so',
    require => Package['php-pear', 'php5-dev', 'libyaml-dev'],
  } ->

  file { '/etc/php5/apache2/conf.d/yaml.ini':
    ensure  => file,
    content => 'extension=yaml.so',
  } ~> Class['apache::service']

  file { '/opt/import':
    ensure => directory,
  }

  $_fileshipper_config = '
[Test Import]
basedir = "/opt/import"
'

  file {
    '/etc/icingaweb2/modules/fileshipper':
      ensure => directory;
    '/etc/icingaweb2/modules/fileshipper/imports.ini':
      ensure  => file,
      content => $_fileshipper_config;
  }
}
