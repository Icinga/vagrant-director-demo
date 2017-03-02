class role::master {
  include ::profile::icinga2
  include ::profile::icingaweb2
  include ::profile::director
}
