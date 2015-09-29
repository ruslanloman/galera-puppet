class galera::config (
    $cluster_name           = $galera::cluster_name,
    $wsrep_cluster_address  = $galera::wsrep_cluster_address,
    $wsrep_node_address     = $galera::wsrep_node_address,
    $sst_user               = $galera::sst_user,
    $sst_pass               = $galera::sst_pass,
    $galera_pid             = '/var/run/mysqld/mysqld.pid',
    $galera_socket          = '/var/run/mysqld/mysqld.sock',
    $service_name           = 'mysql',
    $master_ip               = $galera::master_ip,
){


    file { "/etc/mysql/conf.d/wsrep.cnf" :
        ensure      => present,
        content     => template("galera/wsrep.cnf.erb"),
    } ->

    file { "/etc/mysql/my.cnf" :
        ensure      => present,
        content     => template("galera/my.cnf.erb"),
    } ->

    file { "/usr/lib/ocf/resource.d/mirantis": 
        ensure      => directory,
    } ->

    file { 'mysql-wss-ocf':
        path   => '/usr/lib/ocf/resource.d/mirantis/mysql-wss',
        mode   => '0755',
        owner  => root,
        group  => root,
        source => 'puppet:///modules/galera/ocf/mysql-wss',
    }

    file { '/tmp/wsrep-init-file':
        ensure  => present,
        content => template('galera/wsrep-init-file.erb'),
    }

    if $master_ip == $::ipaddress {
        cs_primitive { "p_${service_name}":
          #ensure          => present,
          primitive_class => 'ocf',
          provided_by     => 'mirantis',
          primitive_type  => 'mysql-wss',
          #metadata        => { 'type' => 'clone','name' => 'p_mysql'},
          parameters      => {
            'test_user'   => "${sst_user}",
            'test_passwd' => "${sst_pass}",
            'pid'         => "${galera_pid}",
            'socket'      => "${galera_socket}",
          },
          operations      => {
            'monitor' => {
              'interval' => '120',
              'timeout'  => '115'
            },
            'start'   => {
              'timeout' => '475'
            },
            'stop'    => {
              'timeout' => '175'
            },
          },
          require    => File[mysql-wss-ocf],
        }

        exec { 'clone_mysql':
            command => '/usr/sbin/crm configure clone clone_mysql p_mysql',
            unless  => '/usr/sbin/crm resource status clone_mysql',
        }
    }
}
