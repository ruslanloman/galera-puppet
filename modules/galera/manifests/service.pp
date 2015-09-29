class galera::service (
    $mysql_service_ensure   = $galera::mysql_service_ensure,
){

      service { 'mysql':
         ensure      => 'stopped',
         enable      => false,
         hasrestart  => true,
         hasstatus   => true,
      }

      #service { 'p_mysql':
      #   ensure      => 'running',
      #   enable      => true,
      #   provider    => 'pacemaker',
      #}
}
