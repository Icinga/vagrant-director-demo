class role::master {
  include ::profile::icinga2
  include ::profile::icingaweb2
  include ::profile::director

  if hiera('icinga2::manage_repo', false) {
    Class['::apt::update']
    -> Class['::icingaweb2::install']
  }
}
