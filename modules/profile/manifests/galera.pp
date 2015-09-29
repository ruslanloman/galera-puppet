class profile::galera {
    $mysql_wsrep_version    = hiera('galera::myqsl_wsrep_version','5.6.16-25.5')
    $galera_version         = hiera('galera::galera_version','25.3.5')
    $mysql_service_ensure   = hiera('galera::mysql_service_ensure','running')
    $cluster_name           = hiera('galera::cluster_name','galera')
    $wsrep_cluster_address  = hiera('galera::wsrep_cluster_address','10.140.21.102:4567,10.140.21.103:4567,10.140.21.104:4567')
    $wsrep_node_address     = $::ipaddress
    $sst_user               = hiera('galera::sst_user','wsrep_sst')
    $sst_pass               = hiera('galera::sst_pass','pa$$word')
    $root_pass              = hiera('galera::root_pass','pa$$word')
    $old_root_pass          = hiera('galera::old_root_pass','')
    $vip                    = hiera('galera::vip','10.140.21.106')
    $master_ip              = hiera('galera::master_ip','10.1240.21.102')

    class { '::corosync':
        enable_secauth      => false,
        bind_address        => $::ipaddress,
        unicast_addresses   => ['10.140.21.102','10.140.21.103','10.140.21.104'],
    }

    corosync::service { 'pacemaker':
      version => '0',
    }

    cs_property { 'stonith-enabled' :
      value   => 'false',
    } 
    cs_property { 'no-quorum-policy' :
      value   => 'ignore',
    }

    class { '::galera':
        wsrep_cluster_address  => $wsrep_cluster_address,
        wsrep_node_address     => $wsrep_node_address,
        master_ip              => $master_ip,
    }
    ->
    sysctl::value { 'net.ipv4.ip_nonlocal_bind':
        value => '1'
    }

    if $master_ip == $::ipaddress {
        cs_primitive { 'vip':
            primitive_class => 'ocf',
            primitive_type  => 'IPaddr2',
            provided_by     => 'heartbeat',
            parameters      => { 'ip' => "$vip", 'cidr_netmask' => '24' },
            operations      => { 'monitor' => { 'interval' => '10s' } },
        }
    }

    class { 'haproxy': }
    haproxy::listen { 'mysql':
        collect_exported => false,
        ipaddress        => $vip,
        ports            => '3306',
        options   => {
            'option'  => ['tcplog', 'clitcpka','srvtcpka','mysql-check user cluster_watcher'],
            'balance' => 'roundrobin',
            'timeout' => ['client  28801s', 'server 28801s'],
        },
    }

    haproxy::balancermember { 'member1':
        listening_service => 'mysql',
        server_names      => 'srv1',
        ipaddresses       => '10.140.21.102',
        ports             => '3306',
        options           => 'check inter 15s fastinter 2s downinter 1s rise 5 fall 3',
    }

    haproxy::balancermember { 'member2':
        listening_service => 'mysql',
        server_names      => 'srv2',
        ipaddresses       => '10.140.21.103',
        ports             => '3306',
        options           => 'backup check inter 15s fastinter 2s downinter 1s rise 5 fall 3',
    }

    haproxy::balancermember { 'member3':
        listening_service => 'mysql',
        server_names      => 'srv3',
        ipaddresses       => '10.140.21.104',
        ports             => '3306',
        options           => 'backup check inter 15s fastinter 2s downinter 1s rise 5 fall 3',
    }
}
