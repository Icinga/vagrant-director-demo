class profile::mysql {
  class { '::mysql::server':
    databases => hiera_hash('mysql::server::databases', { }),
    grants    => hiera_hash('mysql::server::grants', { }),
    users     => hiera_hash('mysql::server::users', { }),
  }
  contain ::mysql::server
  contain ::mysql::client
}
