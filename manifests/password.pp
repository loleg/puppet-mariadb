#
# Class: mariadb::password
#
# Set mariadb password
#
class mariadb::password {

  # Load the variables used in this module. Check the params.pp file
  require mariadb

  file { '/root/.my.cnf':
    ensure  => 'present',
    path    => '/root/.my.cnf',
    mode    => '0400',
    owner   => $mariadb::config_file_owner,
    group   => $mariadb::config_file_group,
    content => template('mariadb/root.my.cnf.erb'),
    # replace => false,
    # require => Exec['mysql_root_password'],
  }

  file { '/root/.my.cnf.backup':
    ensure  => 'present',
    path    => '/root/.my.cnf.backup',
    mode    => '0400',
    owner   => $mariadb::config_file_owner,
    group   => $mariadb::config_file_group,
    content => template('mariadb/root.my.cnf.backup.erb'),
    replace => false,
    before  => [Exec['mysql_root_password'],
                Exec['mysql_backup_root_my_cnf'] ],
  }

  exec { 'mysql_backup_root_my_cnf':
    require     => Service['mysql'],
    path        => '/bin:/sbin:/usr/bin:/usr/sbin',
    unless      => 'diff /root/.my.cnf /root/.my.cnf.backup',
    command     => 'cp /root/.my.cnf /root/.my.cnf.backup ; true',
    before      => File['/root/.my.cnf'],
  }


  exec { 'mysql_root_password':
    subscribe   => File['/root/.my.cnf'],
    require     => Service['mysql'],
    path        => '/bin:/sbin:/usr/bin:/usr/sbin',
    refreshonly => true,
    command     => "mysqladmin --defaults-file=/root/.my.cnf.backup -uroot password '${mariadb::real_root_password}'",
  }

}
