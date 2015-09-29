class galera::install (
    $mysql_wsrep_version    = $galera::mysql_wsrep_version,
    $galera_version         = $galera::galera_version,
    $mysql_service_ensure   = $galera::mysql_service_ensure,
    $mysql_service_enable   = $galera::mysql_service_enable,
    $cluster_name           = $galera::cluster_name,
    $master_ip              = $galera::master_ip,
    $mysql_user             = $galera::sst_user,
    $mysql_password         = $galera::sst_pass,
    $root_password          = $galera::root_pass,
    $old_root_password      = $galera::old_root_pass,
){
    file { ['/etc/mysql', '/etc/mysql/conf.d']:
      ensure => directory,
    } ->

    package { ['psmisc',
               'libaio1',
               'libssl0.9.8',
               'mysql-client',
               'wget']:
      ensure => present, } ->

    exec { "Download_${mysql_wsrep_version}":
      command   => "/usr/bin/wget https://launchpad.net/codership-mysql/5.6/${mysql_wsrep_version}/+download/mysql-server-wsrep-${mysql_wsrep_version}-amd64.deb -O /tmp/mysql-server-wsrep-${mysql_wsrep_version}-amd64.deb",
      onlyif    => "test ! -f /tmp/mysql-server-wsrep-${mysql_wsrep_version}-amd64.deb",
    } ->

    exec { "Download_${galera_version}": 
      command   => "/usr/bin/wget https://launchpad.net/galera/3.x/${galera_version}/+download/galera-${galera_version}-amd64.deb -O /tmp/galera-${galera_version}-amd64.deb",
      onlyif    => "test ! -f /tmp/galera-${galera_version}-amd64.deb",
    } ->

    # Disable service autostart after installation
    file { '/usr/sbin/policy-rc.d':
      ensure  => present,
      content => "/usr/bin/env sh\nexit 101",
      mode    => 0755,
    } ->

    package { "mysql-server-wsrep-${mysql_wsrep_version}":
      ensure   => present,
      provider => "dpkg",
      source   => "/tmp/mysql-server-wsrep-${mysql_wsrep_version}-amd64.deb",
    } ->

    package { "galera-${galera_version}":
      ensure   => present,
      provider => "dpkg",
      source   => "/tmp/galera-${galera_version}-amd64.deb",
    } ->

    file { '/usr/sbin/policy-rc.d': 
      ensure => absent,
    }

    Exec {
      path      => $::path,
      timeout   => '1800',
      tries     => 3,
      try_sleep => '20',
    }
}
