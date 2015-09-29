class galera::params {
    $mysql_wsrep_version    = hiera('galera::myqsl_wsrep_version','5.6.16-25.5')
    $galera_version         = hiera('galera::galera_version','25.3.5')
    $mysql_service_ensure   = hiera('galera::mysql_service_ensure','running')
    $cluster_name           = hiera('galera::cluster_name','galera')
    $wsrep_cluster_address  = hiera('galera::wsrep_cluster_address','192.168.1.153:4567,192.168.1.224:4567')
    $wsrep_node_address     = hiera('galera::wsrep_node_address','192.168.1.101')
    $sst_user               = hiera('galera::sst_user','wsrep_sst')
    $sst_pass               = hiera('galera::sst_pass','pa$$word')
    $root_pass              = hiera('galera::root_pass','pa$$word')
    $old_root_pass          = hiera('galera::old_root_pass','')
    $master_ip              = '127.0.0.1'
}
