class galera::db (
         $root_pass     = $galera::root_pass,
         $sst_user      = $galera::sst_user,
         $sst_pass      = $galera::sst_pass,
         $old_root_pass = $galera::old_root_pass,
){

    case $old_root_password {
      '':      { $old_pw='' }
      default: { $old_pw="-p${old_root_password}" }
    }

    $user_password_string="-u${sst_user} -p${sst_pass}"
    exec { 'wait-initial-sync':
        logoutput   => true,
        command     => "/usr/bin/mysql ${user_password_string} -Nbe \"show status like 'wsrep_local_state_comment'\" | /bin/grep -q -e Synced -e Initialized && sleep 10",
        try_sleep   => 5,
        tries       => 60,
    }->

    exec { 'rm-init-file':
        command => '/bin/rm /tmp/wsrep-init-file',
    }->

    exec { 'wait-for-synced-state':
        logoutput => true,
        command   => "/usr/bin/mysql ${user_password_string} -Nbe \"show status like 'wsrep_local_state_comment'\" | /bin/grep -q Synced && sleep 10",
        try_sleep => 5,
        tries     => 60,
    }->

    exec { 'set_mysql_rootpw':
      command   => "mysqladmin -uroot ${old_pw} password ${root_pass}",
      logoutput => true,
      unless    => "mysqladmin -uroot -p${root_pass} status > /dev/null",
      path      => '/usr/local/sbin:/usr/bin:/usr/local/bin',
    } ->

    file{ ['/etc/my.cnf','/root/.my.cnf']:
        ensure  => present,
        content => template('galera/my.cnf.pass.erb'),
    } ->

    exec { "set-sst-password" :
        unless      => "/usr/bin/mysql -u${sst_user} -p${sst_pass}",
        command     => "/usr/bin/mysql -uroot -p${root_pass} -e \"set wsrep_on='off'; delete from mysql.user where user=''; grant all on *.* to '${sst_user}'@'%' identified by '${sst_pass}';flush privileges;\"",
        refreshonly => true,
        logoutput   => true,
    }
}
