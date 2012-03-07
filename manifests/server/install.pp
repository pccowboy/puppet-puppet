class puppet::server::install {
  package { 'puppet-server': ensure => installed, require => Yumrepo["puppetlabs"] }
  package { 'mysql-devel': ensure => installed }
  package { 'ruby-devel': ensure => '1.8.7.352-1.8.amzn1'}
  package { 'activerecord': ensure => '3.0.9', provider => gem }
  
  service { "puppet":
  	enable 	=> true,
  	ensure 	=> running,
  	name 	=> "puppet",
  	require => [Package["puppet"], Package["mysql"], Service["puppetmaster"]],
  	subscribe => Service["puppetmaster-run-once"],
  }
  
  service { "puppetmaster":
  	enable 	=> false,
  	ensure 	=> stopped,
  	name 	=> "puppetmaster",
  	require => [Package["puppet-server"], Package["mysql"]],
  }

  exec { "puppetmaster-run-once":
    command => "/etc/init.d/puppetmaster start && /puppetmaster stop",
    creates => "/var/lib/puppet/ssl/certs/puppet.${domain}.pem",
    require => Service["puppetmaster"],
    refreshonly => true,
    subscribe => Service["mysqld"],
  }
    
  class { 'mysql::server':
  	config_hash => { 'root_password' => 'password' }
  }

  class { 'mysql': }
  
  mysql::db { 'puppet':
	  user     => 'puppet',
	  password => 'password',
	  host     => 'localhost',
	  grant    => ['all'],
	  sql      => '/bin/echo "use puppet; create index exported_restype_title on resources (exported, restype, title(50));"',
	  subscribe => Service["mysqld"],
	}
}
