class puppet::server::install {
  package { 'puppet-server': ensure => installed, require => Yumrepo["puppetlabs"] }
  package { 'mysql-devel': ensure => installed }
  package { 'ruby-devel': ensure => '1.8.7.352-1.8.amzn1'}
  package { 'activerecord': ensure => installed, provider => gem }
  
  class { 'mysql::server':
  	config_hash => { 'root_password' => 'password' }
  }

  class { 'mysql': }
  
  mysql::db { 'puppet':
	  user     => 'puppet',
	  password => 'password',
	  host     => 'localhost',
	  grant    => ['all'],
	  sql      => 'echo "create index exported_restype_title on resources (exported, restype, title(50));"',
	}
}
