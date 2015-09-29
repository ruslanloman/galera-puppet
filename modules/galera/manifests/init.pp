class galera(
    $mysql_wsrep_version    = $galera::params::mysql_wsrep_version,
    $galera_version         = $galera::params::galera_version,
    $mysql_service_ensure   = $galera::params::mysql_service_ensure,
    $cluster_name	    = $galera::params::cluster_name, 
    $wsrep_cluster_address  = $galera::params::wsrep_cluster_address,
    $wsrep_node_address     = $galera::params::wsrep_node_address,
    $mysql_user             = $galera::params::sst_user,
    $mysql_pass             = $galera::params::sst_pass,
    $root_pass              = $galera::params::root_pass,
    $old_root_pass          = $galera::params::old_root_pass,
    $master_ip              = $galera::params::master_ip,
) inherits params {
   
   anchor { 'galera::start': }
     -> class { 'galera::install': }
     -> class { 'galera::config': }
     ~> class { 'galera::service': }
     -> class { 'galera::db': }
   anchor { 'galera::end': }
}
